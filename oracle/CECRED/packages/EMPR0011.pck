CREATE OR REPLACE PACKAGE CECRED.EMPR0011 IS

  /* Type das parcelas do Pos-Fixado */
  TYPE typ_reg_tab_parcelas IS RECORD(
       nrparepr     crappep.nrparepr%TYPE
      ,vlparepr     crappep.vlparepr%TYPE
      ,dtvencto     crappep.dtvencto%TYPE
      ,dtultpag     crappep.dtultpag%TYPE
      ,insitpar     PLS_INTEGER -- (1 - Em dia, 2 - Vencida, 3 - A Vencer)
      ,vlpagpar     crappep.vlpagpar%TYPE
      ,vlmtapar     crappep.vlmtapar%TYPE
      ,vlmrapar     crappep.vlmrapar%TYPE
      ,vliofcpl     crappep.vliofcpl%TYPE
      ,vlsdvpar     crappep.vlsdvpar%TYPE
      ,vldescto     crappep.vldespar%TYPE
      ,vlpraven     crappep.vlsdvpar%TYPE
      ,vlatupar     NUMBER(25,2)
      ,vlatrpag     NUMBER(25,2)
      ,flcarenc     PLS_INTEGER
      ,vlrdtaxa     craptxi.vlrdtaxa%TYPE
      ,taxa_periodo NUMBER(25,10)
      ,vliofpri     NUMBER(25,2)
      ,vliofadc     NUMBER(25,2)
      ,vldstcor     crappep.vldstcor%TYPE
      ,vldstcor_atu crappep.vldstcor%TYPE
      ,vldstrem     crappep.vldstrem%TYPE
      ,vldstrem_atu crappep.vldstrem%TYPE      
      ,dtdstjur     crappep.dtdstjur%TYPE
			,inliquid     crappep.inliquid%TYPE
			);
      
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_parcelas IS TABLE OF typ_reg_tab_parcelas INDEX BY BINARY_INTEGER;

	/* Tipo que compreende o registro da tab. temporaria tt-calculado */
  TYPE typ_reg_calculado IS RECORD(
     vlsdeved NUMBER(25, 10)
    ,vlsderel NUMBER(25, 10)
		);

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_calculado IS TABLE OF typ_reg_calculado INDEX BY BINARY_INTEGER;

  /* Type para armazenar o Saldo Projetado */
  TYPE typ_reg_tab_saldo_projetado IS RECORD(
       taxa_periodo         NUMBER(25,8) := 0
      ,juros_correcao       NUMBER(25,2) := 0
      ,juros_remuneratorio  NUMBER(25,2) := 0
      ,saldo_projetado      NUMBER(25,2) := 0
      ,saldo_devedor        NUMBER(25,2) := 0);
    
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_saldo_projetado IS TABLE OF typ_reg_tab_saldo_projetado INDEX BY BINARY_INTEGER;  
  
  /* Type de Total de Juros por Parcela do Pos Fixado */
  TYPE typ_reg_tab_total_juros IS RECORD(
       nrparepr           crappep.nrparepr%TYPE
      ,valor_total_juros  NUMBER(25,10));
    
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_total_juros IS TABLE OF typ_reg_tab_total_juros INDEX BY BINARY_INTEGER;
    
  /* Type das parcelas do Pos-Fixado */
  TYPE typ_reg_tab_price IS RECORD(
       taxa_periodo         NUMBER(25,8)  := 0
      ,fator_juros_nominais NUMBER(25,10) := 0
      ,fator_correcao       NUMBER(25,10) := 0
      ,fator_acumulado      NUMBER(25,10) := 0
      ,fator_price          NUMBER(25,10) := 0
      ,vlrdtaxa             craptxi.vlrdtaxa%TYPE);
        
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_price IS TABLE OF typ_reg_tab_price INDEX BY BINARY_INTEGER;
  
  -- Tipos e tabelas de memória para armazenar os dados do feriado
  TYPE typ_tab_feriado IS
    TABLE OF crapfer.dtferiad%TYPE
      INDEX BY VARCHAR2(20); --> A chave será a cdcooper(10) + data(10)
  -- Vetor para armazenamento
  vr_tab_feriado typ_tab_feriado;
  
  TYPE typ_reg_craplcr IS RECORD
    (perjurmo craplcr.perjurmo%TYPE,
     percmult NUMBER);
  TYPE typ_tab_craplcr IS TABLE OF typ_reg_craplcr INDEX BY VARCHAR2(20);
  -- Vetor para armazenamento
  vr_tab_craplcr typ_tab_craplcr;
  
  PROCEDURE pc_calcula_qtd_dias_uteis(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_flgbatch     IN BOOLEAN DEFAULT FALSE --> Indica se o processo noturno estah rodando
                                     ,pr_dtefetiv     IN crapepr.dtmvtolt%TYPE --> Data de Efetivação da Proposta
                                     ,pr_datainicial  IN DATE                  --> Data Inicial
                                     ,pr_datafinal    IN DATE                  --> Data Final
                                     ,pr_qtdiaute    OUT PLS_INTEGER           --> Quantidade de dias uteis
                                     ,pr_cdcritic    OUT PLS_INTEGER           --> Codigo da critica
                                     ,pr_dscritic    OUT VARCHAR2 );
                                     
  PROCEDURE pc_calcula_dias360(pr_ehmensal   IN BOOLEAN                -- Indica se juros esta rodando na mensal
                              ,pr_dtvencto   IN crappep.dtvencto%TYPE  --> Data de Vencimento
                              ,pr_dtrefjur   IN DATE                   --> Data de Referencia do lancamento de juros
                              ,pr_data_final IN DATE                   --> Data Final
                              ,pr_qtdedias   OUT PLS_INTEGER            --> Quantidade de Dias entre duas Datas
                              ,pr_cdcritic   OUT PLS_INTEGER           --> Codigo da critica
                              ,pr_dscritic   OUT VARCHAR2);                                     
  
  PROCEDURE pc_calcula_saldo_projetado(pr_cdcooper            IN  crapepr.cdcooper%TYPE         --> Codigo da Cooperativa
                                      ,pr_flgbatch            IN  BOOLEAN DEFAULT FALSE         --> Indica se o processo noturno estah rodando
                                      ,pr_dtefetiv            IN  crapepr.dtmvtolt%TYPE         --> Data de Efetivação da Proposta
                                      ,pr_datainicial         IN  DATE                          --> Data Inicial
                                      ,pr_datafinal           IN  DATE                          --> Data Calculo
                                      ,pr_nrparepr            IN  crappep.nrparepr%TYPE         --> Numero da Parcela
                                      ,pr_dtvencto            IN  crappep.dtvencto%TYPE         --> Data de vencimento da parcela
                                      ,pr_vlparepr_principal  IN  crappep.vlparepr%TYPE := 0    --> Valor da Parcela Principal
                                      ,pr_vlrdtaxa            IN  craptxi.vlrdtaxa%TYPE         --> Taxa do CDI/TR
                                      ,pr_dtdpagto            IN  crapepr.dtdpagto%TYPE         --> Data de Pagamento
                                      ,pr_txmensal            IN  crapepr.txmensal%TYPE         --> Taxa Mensal do Emprestimo
                                      ,pr_vlsprojt            IN  crapepr.vlsprojt%TYPE         --> Saldo Projetado
                                      ,pr_tab_saldo_projetado IN OUT typ_tab_saldo_projetado    --> Tabela contendo os valores de Saldo Projetado
                                      ,pr_tab_total_juros     IN OUT typ_tab_total_juros        --> Tabela contendo as parcelas
                                      ,pr_cdcritic            OUT crapcri.cdcritic%TYPE         --> Codigo da critica
                                      ,pr_dscritic            OUT crapcri.dscritic%TYPE);
  
  PROCEDURE pc_calcula_prox_parcela_pos(pr_cdcooper        IN  crapepr.cdcooper%TYPE --> Codigo da Cooperativa
                                       ,pr_flgbatch        IN  BOOLEAN DEFAULT FALSE --> Indica se o processo noturno estah rodando
                                       ,pr_dtcalcul        IN  crapdat.dtmvtolt%TYPE --> Data do cálculo
                                       ,pr_nrdconta        IN  crapepr.nrdconta%TYPE --> Numero da Conta Corrente
                                       ,pr_nrctremp        IN  crapepr.nrctremp%TYPE --> Numero do Contrato
                                       ,pr_dtefetiv        IN  crapepr.dtmvtolt%TYPE --> Data de efetivação da proposta
                                       ,pr_dtdpagto        IN  crawepr.dtdpagto%TYPE --> Data do Primeiro Pagamento
                                       ,pr_txmensal        IN  crapepr.txmensal%TYPE --> Taxa Mensal do Contrato
                                       ,pr_vlrdtaxa        IN  craptxi.vlrdtaxa%TYPE --> Valor da Taxa
                                       ,pr_qtpreemp        IN  crapepr.qtpreemp%TYPE --> Quantidade de Prestacoes do Emprestimo
                                       ,pr_vlsprojt        IN  crapepr.vlsprojt%TYPE --> Saldo Devedor Projetado
                                       ,pr_vlemprst        IN  crawepr.vlemprst%TYPE --> Valor do Emprestimo
                                       ,pr_nrparepr        IN  crappep.nrparepr%TYPE --> Numero da Parcela
                                       ,pr_dtvencto        IN  crappep.dtvencto%TYPE --> Data de Vencimento da Parcela                                   
                                       ,pr_qtdias_carencia IN  tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias de Carencia
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
                                       
  PROCEDURE pc_calc_parc_pos_fixado_prog(pr_cdcooper        IN  crapcop.cdcooper%TYPE                    -- Codigo da Cooperativa
																				,pr_dtcalcul        IN  crapdat.dtmvtolt%TYPE                    -- Data de Calculo
																				,pr_cdlcremp        IN  craplcr.cdlcremp%TYPE                    -- Codigo da Linha de Credito
																				,pr_dtcarenc        IN  crawepr.dtcarenc%TYPE                    -- Data da Carencia do Contrato
																				,pr_qtdias_carencia IN  tbepr_posfix_param_carencia.qtddias%TYPE -- Quantidade de Dias de Carencia
																				,pr_dtdpagto        IN  crapepr.dtdpagto%TYPE                    -- Data de Pagamento
																				,pr_qtpreemp        IN  crapepr.qtpreemp%type                    -- Quantidade de Prestacoes
																				,pr_vlemprst        IN  crapepr.vlemprst%TYPE                    -- Valor do Emprestimo
																				,pr_tab_parcelas    OUT CLOB                                     -- Parcelas do Emprestimo
																				,pr_cdcritic        OUT crapcri.cdcritic%TYPE                    -- Codigo da critica
																				,pr_dscritic        OUT crapcri.dscritic%TYPE                    -- Descricao da critica
		                                    );
	
  PROCEDURE pc_calcula_atraso_pos_fixado (pr_cdcooper IN  crappep.cdcooper%TYPE   --> Codigo da Cooperativa
                                         ,pr_cdprogra IN  crapprg.cdprogra%TYPE   --> Codigo do Programa
                                         ,pr_nrdconta IN  crappep.nrdconta%TYPE   --> Numero da Conta Corrente
                                         ,pr_nrctremp IN  crappep.nrctremp%TYPE   --> Numero do Contrato
                                         ,pr_cdlcremp IN  crapepr.cdlcremp%TYPE   --> Linha de Credito
                                         ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE   --> Data de Calculo
                                         ,pr_vlemprst IN  crapepr.vlemprst%TYPE   --> Valor do Emprestimo 
                                         ,pr_nrparepr IN  crappep.nrparepr%TYPE   --> Numero da Parcela do Emprestimo
                                         ,pr_vlparepr IN  crappep.vlparepr%TYPE   --> Valor da Parcela
                                         ,pr_dtvencto IN  crappep.dtvencto%TYPE   --> Data de Vencimento da Parcela
                                         ,pr_dtultpag IN  crappep.dtultpag%TYPE   --> Data do Ultimo Pagamento
                                         ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE   --> Saldo Devedor da Parcela
                                         ,pr_perjurmo IN  craplcr.perjurmo%TYPE   --> Percentual do Juros de Mora
                                         ,pr_vlpagmta IN  crappep.vlpagmta%TYPE   --> Valor Pago de Mula
                                         ,pr_percmult IN  NUMBER                  --> Percentual de Multa
                                         ,pr_txmensal IN  crapepr.txmensal%TYPE   --> Taxa mensal do Emprestimo
                                         ,pr_qttolatr IN  crapepr.qttolatr%TYPE   --> Quantidade de Tolerancia para Cobrar Multa/Juros de Mora
                                         ,pr_vlmrapar OUT NUMBER                  --> Juros de Mora Atualizado
                                         ,pr_vlmtapar OUT NUMBER                  --> Multa Atualizado
                                         ,pr_vliofcpl OUT NUMBER                  --> IOF Complementar em Atraso
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo da critica
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_calcula_desconto_pos_web(pr_dtmvtolt     IN VARCHAR2              --> Data de Movimento Atual
                                       ,pr_dtmvtoan     IN VARCHAR2              --> Data de Movimento Anterior
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
                                       ,pr_des_erro    OUT VARCHAR2);
                                      
  PROCEDURE pc_busca_pagto_parc_pos(pr_cdcooper     IN  crapepr.cdcooper%TYPE      --> Codigo da Cooperativa
                                   ,pr_cdprogra     IN  crapprg.cdprogra%TYPE      --> Codigo do Programa
                                   ,pr_flgbatch     IN  BOOLEAN DEFAULT FALSE      --> Indica se o processo noturno estah rodando
                                   ,pr_dtmvtolt     IN  crapdat.dtmvtolt%TYPE      --> Data de calculo das parcelas
                                   ,pr_dtmvtoan     IN  crapdat.dtmvtoan%TYPE      --> Data do movimento anterior
                                   ,pr_nrdconta     IN  crapepr.nrdconta%TYPE      --> Numero da Conta Corrente
                                   ,pr_nrctremp     IN  crapepr.nrctremp%TYPE      --> Numero do Contrato
                                   ,pr_dtefetiv     IN  crapepr.dtmvtolt%TYPE      --> Data de Efetivacao do Contrato de Emprestimo
                                   ,pr_cdlcremp     IN  crapepr.cdlcremp%TYPE      --> Codigo da linha de credito
                                   ,pr_vlemprst     IN crapepr.vlemprst%TYPE       --> Valor do Emprestimo
                                   ,pr_txmensal     IN  crawepr.txmensal%TYPE      --> Taxa Mensal do Contrato de Emprestimo
                                   ,pr_dtdpagto     IN  crawepr.dtdpagto%TYPE      --> Data de Pagamento do Primeiro Vencimento
                                   ,pr_vlsprojt     IN  crapepr.vlsprojt%TYPE      --> Saldo Devedor Projetado
                                   ,pr_qttolatr     IN  crapepr.qttolatr%TYPE      --> Tolerancia para cobranca de multa e mora parcelas atraso
                                   ,pr_tab_parcelas OUT EMPR0011.typ_tab_parcelas --> Temp-Table contendo todas as parcelas calculadas
																	 ,pr_tab_calculado OUT empr0011.typ_tab_calculado --> Tabela com totais calculados
                                   ,pr_cdcritic     OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                   ,pr_dscritic     OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_busca_pagto_parc_pos_prog(pr_cdcooper  IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                        ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Codigo do Programa
                                        ,pr_dtmvtolt  IN VARCHAR2                  --> Data de calculo das parcelas
                                        ,pr_dtmvtoan  IN VARCHAR2                  --> Data de movimento anterior
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do Contrato
                                        ,pr_vlsdeved OUT NUMBER                    --> Valor atualizado
                                        ,pr_vlprvenc OUT NUMBER                    --> Parcela Vencida
                                        ,pr_vlpraven OUT NUMBER                    --> Parcela EM DIA + Parcela A VENCER
                                        ,pr_vlmtapar OUT NUMBER                    --> Valor da multa por atraso
                                        ,pr_vlmrapar OUT NUMBER                    --> Valor de juros pelo atraso
                                        ,pr_vliofcpl OUT NUMBER                    --> Valor de juros pelo atraso
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_busca_pagto_parc_pos_web(pr_cdcooper     IN crapepr.cdcooper%TYPE      --> Codigo da Cooperativa
                                       ,pr_dtmvtolt     IN VARCHAR2                   --> Data de calculo das parcelas
                                       ,pr_dtmvtoan     IN VARCHAR2 DEFAULT NULL      --> Data de movimento anterior
                                       ,pr_nrdconta     IN crapepr.nrdconta%TYPE      --> Numero da Conta Corrente
                                       ,pr_nrctremp     IN crapepr.nrctremp%TYPE      --> Numero do Contrato
                                       ,pr_xmllog       IN VARCHAR2                   --> XML com informacoes de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER                --> Codigo da critica
                                       ,pr_dscritic    OUT VARCHAR2                   --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype             --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2                   --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2);                 --> Erros do processo

  PROCEDURE pc_calcula_juros_remuneratorio(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                          ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento do Dia Anterior
                                          ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual                                      
                                          ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                          ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                          ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de Liberacao do Contrato
                                          ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                          ,pr_insitpar IN  PLS_INTEGER DEFAULT NULL  --> Situacao da Parcela
                                          ,pr_vlsprojt IN  crapepr.vlsdeved%TYPE     --> Valor do Saldo Devedor Projetado
                                          ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando na mensal
                                          ,pr_txdiaria IN  NUMBER                    --> Taxa Diaria do Contrato
                                          ,pr_diarefju IN OUT crapepr.diarefju%TYPE  --> Dia de Referencia de Juros
                                          ,pr_mesrefju IN OUT crapepr.mesrefju%TYPE  --> Mes de Referencia do Juros
                                          ,pr_anorefju IN OUT crapepr.anorefju%TYPE  --> Ano de Referencia do Juros
                                          ,pr_vljuremu OUT NUMBER                    --> Juros Remuneratorios
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_calcula_juros_correcao(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                     ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento Anterior
                                     ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual
                                     ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                     ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente                                        
                                     ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                     ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de liberacao do Contrato
                                     ,pr_dtrefjur IN  crapepr.dtrefjur%TYPE     --> Data de Referencia de Juros
                                     ,pr_vlrdtaxa IN  NUMBER                    --> Valor da Taxa de Atualizacao da Parcela
                                     ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                     ,pr_insitpar IN  PLS_INTEGER DEFAULT NULL  --> Situacao da Parcela
                                     ,pr_vlsprojt IN  NUMBER                    --> Saldo Devedor Projetado
                                     ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                     ,pr_dtrefcor IN  crapepr.dtrefcor%TYPE     --> Data de Referencia do ultimo lancamento de juros de correcao
                                     ,pr_vljurcor OUT NUMBER                    --> Juros de Correcao
                                     ,pr_qtdiacal OUT craplem.qtdiacal%TYPE     --> Quantidade de dias de calculo
                                     ,pr_vltaxprd OUT craplem.vltaxprd%TYPE     --> Taxa no Periodo
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE);
                                     
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

  PROCEDURE pc_grava_parcel_pos_fixado(pr_cdcooper         IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_nrdconta         IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_dtcalcul         IN crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                      ,pr_nrctremp         IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_cdlcremp         IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_vlemprst         IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                      ,pr_qtparepr         IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                      ,pr_dtcarenc         IN crawepr.dtcarenc%TYPE     --> Data da Carência
                                      ,pr_dtdpagto         IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_qtdias_carencia  IN tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias
                                      ,pr_vlpreemp        OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                      ,pr_txdiaria        OUT crawepr.txdiaria%TYPE     --> Taxa diaria
                                      ,pr_txmensal        OUT crawepr.txmensal%TYPE     --> Taxa mensal
                                      ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic        OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_busca_vl_prest_pos_prog(pr_cdcooper         IN crapepr.cdcooper%TYPE   --> Codigo da Cooperativa
                                      ,pr_dtcalcul         IN crapdat.dtmvtoan%TYPE   --> Data de Calculo
                                      ,pr_cdlcremp         IN crapepr.cdlcremp%TYPE   --> Codigo da linha de credito
                                      ,pr_qtpreemp         IN crapepr.qtpreemp%TYPE   --> Quantidade de prestacoes
                                      ,pr_dtcarenc         IN crawepr.dtcarenc%TYPE   --> Data de Pagamento da Primeira Carência
                                      ,pr_dtdpagto         IN crapepr.dtdpagto%TYPE   --> Data do pagamento
                                      ,pr_vlsdeved         IN crapepr.vlsdeved%TYPE   --> Valor do saldo devedor
                                      ,pr_qtdias_carencia  IN tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias
                                      ,pr_vlpreemp        OUT crapepr.vlpreemp%TYPE   --> Valor da prestacao
                                      ,pr_cdcritic        OUT crapcri.cdcritic%TYPE   --> Codigo da critica
                                      ,pr_dscritic        OUT crapcri.dscritic%TYPE); --> Descricao da critica

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

  PROCEDURE pc_busca_qtd_dias_carencia(pr_idcarencia  IN tbepr_posfix_param_carencia.idcarencia%TYPE --> Codigo da Carencia
                                      ,pr_qtddias    OUT tbepr_posfix_param_carencia.qtddias%TYPE    --> Quantidade de Dias
                                      ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                       --> Codigo da critica
                                      ,pr_dscritic   OUT crapcri.dscritic%TYPE);                     --> Descricao da critica
  
  PROCEDURE pc_efetua_lcto_juros_remun(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento do Dia Anterior
                                      ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual                                      
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
                                      ,pr_insitpar IN  PLS_INTEGER DEFAULT NULL  --> Situacao da Parcela
                                      ,pr_vlsprojt IN  crapepr.vlsdeved%TYPE     --> Valor do Saldo Devedor Projetado
                                      ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                      ,pr_txdiaria IN  NUMBER                    --> Taxa Diaria do Contrato
                                      ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                      ,pr_diarefju IN OUT crapepr.diarefju%TYPE     --> Dia de Referencia de Juros
                                      ,pr_mesrefju IN OUT crapepr.mesrefju%TYPE     --> Mes de Referencia do Juros
                                      ,pr_anorefju IN OUT crapepr.anorefju%TYPE     --> Ano de Referencia do Juros
                                      ,pr_vljuremu OUT NUMBER                    --> Juros Remuneratorios
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_efetua_lcto_juros_correc (pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                        ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento do Dia Anterior
                                        ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual
                                        ,pr_cdagenci IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                        ,pr_cdpactra IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                        ,pr_cdoperad IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                        ,pr_cdorigem IN  NUMBER                    --> Codigo da Origem
                                        ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                        ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente                                        
                                        ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                        ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de liberacao do Contrato
                                        ,pr_dtrefjur IN  crapepr.dtrefjur%TYPE     --> Data de Referencia de Juros
                                        ,pr_diarefju IN  crapepr.diarefju%TYPE     --> Dia de Referencia de Juros
                                        ,pr_mesrefju IN  crapepr.mesrefju%TYPE     --> Mes de Referencia do Juros
                                        ,pr_anorefju IN  crapepr.anorefju%TYPE     --> Ano de Referencia do Juros
                                        ,pr_vlrdtaxa IN  NUMBER                    --> Valor da Taxa de Atualizacao da Parcela
                                        ,pr_txjuremp IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                        ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE     --> Valor da prestacao do Emprestimo
                                        ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                        ,pr_insitpar IN  PLS_INTEGER DEFAULT NULL  --> Situacao da Parcela
                                        ,pr_vlsprojt IN  NUMBER                    --> Saldo Devedor Projetado
                                        ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                        ,pr_floperac IN  BOOLEAN                   --> Indicador se a Operacao eh Financiamento
                                        ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                        ,pr_dtrefcor IN  crapepr.dtrefcor%TYPE     --> Data de Referencia do ultimo lancamento de juros de correcao
                                        ,pr_vljurcor OUT NUMBER                    --> Juros de Correcao
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_efetua_pagamento_em_dia(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_cdprogra IN  crapprg.cdprogra%TYPE     --> Nome da Tela
                                      ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento do Dia Anterior
                                      ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual
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
                                      ,pr_diarefju IN  crapepr.diarefju%TYPE     --> Dia de Referencia de Lancamento de Juros
                                      ,pr_mesrefju IN  crapepr.mesrefju%TYPE     --> Mes de Referencia de Lancamento de Juros
                                      ,pr_anorefju IN  crapepr.anorefju%TYPE     --> Ano de Referente de Lancamento de Juros
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
                                      ,pr_dtrefcor IN  crapepr.dtrefcor%TYPE     --> Data de Referencia do ultimo lancamento de juros de correcao
                                      ,pr_txmensal IN  crapepr.txmensal%TYPE     --> Taxa Mensal do Contrato
                                      ,pr_dtdstjur IN  crappep.dtdstjur%TYPE     --> Data da ultima correcao do valor pago
                                      ,pr_vlpagpar_atu IN crappep.vlpagpar%TYPE  --> Valor Ja Pago da Parcela
                                      ,pr_nmdatela  IN VARCHAR2 DEFAULT 'EMPR0011' --> Nome da tela
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_efetua_pagamento_em_atraso(pr_cdcooper IN  crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                         ,pr_cdprogra IN  crapprg.cdprogra%TYPE     --> Nome da Tela
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
                                         ,pr_cdlcremp IN  crapepr.cdlcremp%TYPE     --> Linha de Credito
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
                                         ,pr_txmensal IN  crapepr.txmensal%TYPE     --> Taxa Mensal do Emprestimo
                                         ,pr_idfiniof IN  crawepr.idfiniof%TYPE     --> Indicador para financiar IOF
                                         ,pr_vlemprst IN  crapepr.vlemprst%TYPE     --> Valor do Emprestimo
                                         ,pr_nmdatela IN  VARCHAR2 DEFAULT 'EMPR0011' --> Nome da tela
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE);

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

  PROCEDURE pc_gera_pagto_pos(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                             ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Codigo do Programa
                             ,pr_dtcalcul  IN crapdat.dtmvtolt%TYPE --> Data de calculo das parcelas
                             ,pr_flgbatch  IN BOOLEAN DEFAULT FALSE --> Definir se estah rodando o pagamento no batch
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                             ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero do contrato
                             ,pr_nrparepr  IN crappep.nrparepr%TYPE --> Numero da parcela
                             ,pr_vlpagpar  IN crappep.vlparepr%TYPE --> Valor para pagamento da parcela
                             ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Sequencia do titular
                             ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo da Agencia
                             ,pr_cdpactra  IN crapage.cdagenci%TYPE --> Codigo da Agencia Trabalho
                             ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE --> Numero do caixa
                             ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                             ,pr_nrseqava  IN PLS_INTEGER           --> Sequencia de pagamento de avalista
                             ,pr_idorigem  IN PLS_INTEGER           --> Codigo de origem
                             ,pr_nmdatela  IN VARCHAR2              --> Nome da tela
                             ,pr_tab_price IN OUT typ_tab_price     --> Temp-Table contendo o o Price de Desconto das Parcelas
                             ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

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

  PROCEDURE pc_busca_prest_principal_pos(pr_cdcooper         IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                        ,pr_dtefetiv         IN crapepr.dtmvtolt%TYPE     --> Data de Efetivação do Emprestimo
                                        ,pr_dtcalcul         IN crapdat.dtmvtolt%TYPE     --> Data de calculo das parcelas
                                        ,pr_cdlcremp         IN craplcr.cdlcremp%TYPE     --> Codigo da Linha de Credito
                                        ,pr_dtcarenc         IN crawepr.dtcarenc%TYPE     --> Data de Pagamento da Primeira Carencia
                                        ,pr_dtdpagto         IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                        ,pr_qtpreemp         IN crapepr.qtpreemp%TYPE     --> Quantidade de prestacoes
                                        ,pr_vlemprst         IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                        ,pr_qtdias_carencia  IN tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias
                                        ,pr_vlpreemp        OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                        ,pr_vljurcor        OUT crapepr.vlpreemp%TYPE     --> Valor do Juros de Correcao
                                        ,pr_cdcritic            OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE);   --> Descricao da critica

  PROCEDURE pc_retorna_val_parc_pos_fixado(pr_cdcooper        IN  crapcop.cdcooper%TYPE                    -- Codigo da Cooperativa
                                          ,pr_dtcalcul        IN  crapdat.dtmvtolt%TYPE                    -- Data de Calculo
                                          ,pr_cdlcremp        IN  craplcr.cdlcremp%TYPE                    -- Codigo da Linha de Credito
                                          ,pr_dtcarenc        IN  crawepr.dtcarenc%TYPE                    -- Data da Carencia do Contrato
                                          ,pr_qtdias_carencia IN  tbepr_posfix_param_carencia.qtddias%TYPE -- Quantidade de Dias de Carencia
                                          ,pr_dtdpagto        IN  crapepr.dtdpagto%TYPE                    -- Data de Pagamento
                                          ,pr_qtpreemp        IN  crapepr.qtpreemp%type                    -- Quantidade de Prestacoes
                                          ,pr_vlemprst        IN  crapepr.vlemprst%TYPE                    -- Valor do Emprestimo
                                          ,pr_vlprecar        OUT crapepr.vlemprst%TYPE                    -- Valor da prestacao carencia
																					,pr_vlpreemp        OUT crapepr.vlemprst%TYPE                    -- Valor da prestacao emprestimo
                                          ,pr_cdcritic        OUT crapcri.cdcritic%TYPE                    -- Codigo da critica
                                          ,pr_dscritic        OUT crapcri.dscritic%TYPE                    -- Descricao da critica
																					);

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
  --  Data     : Abril - 2017                 Ultima atualizacao: 21/01/2019
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas para calculo do emprestimo Pos-Fixado.
  --
  -- Alteracoes: 14/08/2018 - Pagamento de Emprestimo - Impedir o lançamento na c.c. quando a origem vier
  --                          da tela pr_nmtela = 'BLQPREJU'  Rangel Decker (AMcom)
  --                          -pc_efetua_pagamento_em_dia
  --                          -pc_efetua_pagamento_em_atraso
  --                          -pc_efetua_pagamento_vencer
	--
	--             12/12/2018 - PRJ298.2 - Permitir a simulacao das parcelas do pos-fixado
	--             08/01/2018 - PRJ298.2.2 - Ajustar e validar rotinas respeitando aplicação da varição do indexador - Nagasava (Supero)
	--             21/01/2019 - PRJ298.2.2 - Ajuste para "Atualização da Dívida após a transferência do prejuízo" - Nagasava (Supero)
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
          IF vr_tab_feriado.COUNT = 0 THEN
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
                                  ,pr_tab_price         IN OUT typ_tab_price      --> Temp-Table das parcelas
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
      vr_qtprice_calc          PLS_INTEGER;
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
      -- Transformar a taxa mensal para taxa diaria
      vr_txdiaria     := POWER(1 + (NVL(pr_txmensal,0) / 100),(1 / 30)) - 1;
      vr_data_inicial := ADD_MONTHS(pr_dtvencto,-1);
      vr_data_final   := pr_dtvencto;
      
      -- Condicao para verificar qual data inicial será calculada
      IF pr_dtefetiv >= vr_data_inicial THEN
        vr_data_inicial := pr_dtefetiv;
      END IF;
      
      -- Quantidade de Price Calculado
      vr_qtprice_calc := pr_tab_price.COUNT + 1;      
      -- Calcular o Fator Price para cada parcela
      FOR vr_indice IN vr_qtprice_calc..pr_qtparcel LOOP
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
        IF TO_CHAR(pr_dtefetiv,'mmyyyy') = TO_CHAR(pr_dtvencto,'mmyyyy') AND NOT pr_tab_price.EXISTS(pr_tab_price.LAST -1) THEN
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
        IF pr_tab_price.EXISTS(pr_tab_price.LAST - 1) THEN
                                                          -- Fator Acumulado da parcela Anterior
          pr_tab_price(vr_indice).fator_juros_nominais := (pr_tab_price(pr_tab_price.LAST -1).fator_acumulado * 
                                                          -- Calculo do Juros Nominais
                                                          (POWER(1 + vr_txdiaria,vr_qtdia_corridos) - 1)) +
                                                          -- Fator Juros Nominais da parcela Anterior
                                                          pr_tab_price(pr_tab_price.LAST -1).fator_juros_nominais;

          -- Calculo do Fator Correcao Monetaria      -- Fator Acumulado da parcela Anterior
          pr_tab_price(vr_indice).fator_correcao := (pr_tab_price(pr_tab_price.LAST -1).fator_acumulado * 
                                                    (((1 + vr_taxa_periodo_anterior) * pr_tab_price(vr_indice).taxa_periodo) + vr_taxa_periodo_anterior)) +
                                                    pr_tab_price(pr_tab_price.LAST -1).fator_correcao;

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

  PROCEDURE pc_calcula_saldo_projetado(pr_cdcooper            IN  crapepr.cdcooper%TYPE         --> Codigo da Cooperativa
                                      ,pr_flgbatch            IN  BOOLEAN DEFAULT FALSE         --> Indica se o processo noturno estah rodando
                                      ,pr_dtefetiv            IN  crapepr.dtmvtolt%TYPE         --> Data de Efetivação da Proposta
                                      ,pr_datainicial         IN  DATE                          --> Data Inicial
                                      ,pr_datafinal           IN  DATE                          --> Data Calculo
                                      ,pr_nrparepr            IN  crappep.nrparepr%TYPE         --> Numero da Parcela
                                      ,pr_dtvencto            IN  crappep.dtvencto%TYPE         --> Data de vencimento da parcela
                                      ,pr_vlparepr_principal  IN  crappep.vlparepr%TYPE := 0    --> Valor da Parcela Principal
                                      ,pr_vlrdtaxa            IN  craptxi.vlrdtaxa%TYPE         --> Taxa do CDI/TR
                                      ,pr_dtdpagto            IN  crapepr.dtdpagto%TYPE         --> Data de Pagamento
                                      ,pr_txmensal            IN  crapepr.txmensal%TYPE         --> Taxa Mensal do Emprestimo
                                      ,pr_vlsprojt            IN  crapepr.vlsprojt%TYPE         --> Saldo Projetado
                                      ,pr_tab_saldo_projetado IN OUT typ_tab_saldo_projetado    --> Tabela contendo os valores de Saldo Projetado
                                      ,pr_tab_total_juros     IN OUT typ_tab_total_juros        --> Tabela contendo as parcelas
                                      ,pr_cdcritic            OUT crapcri.cdcritic%TYPE         --> Codigo da critica
                                      ,pr_dscritic            OUT crapcri.dscritic%TYPE) IS
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
      vr_valor_total_juros          NUMBER(25,2) := 0;
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
                        ,pr_dtvencto   => pr_dtvencto
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
      
      vr_indice := pr_tab_saldo_projetado.COUNT;
      IF pr_tab_saldo_projetado.EXISTS(vr_indice) THEN
        vr_saldo_juros_correcao      := pr_tab_saldo_projetado(vr_indice).saldo_projetado;
        vr_saldo_juros_remuneratorio := pr_tab_saldo_projetado(vr_indice).saldo_projetado;
        vr_saldo_projetado           := pr_tab_saldo_projetado(vr_indice).saldo_projetado;
      ELSE
        vr_saldo_juros_correcao      := pr_vlsprojt;
        vr_saldo_juros_remuneratorio := pr_vlsprojt;
        vr_saldo_projetado           := pr_vlsprojt;
      END IF;
      
      vr_indice := pr_tab_saldo_projetado.COUNT + 1;
      -- Calculo da taxa no periodo
      pr_tab_saldo_projetado(vr_indice).taxa_periodo := POWER((1 + (pr_vlrdtaxa / 100)),(vr_qtdia_uteis / 252)) - 1;
          
      --------------------------------------------------------------------------------------------------
      --  Condicao para verificar se estamos calculando o vencimento da Parcela
      --------------------------------------------------------------------------------------------------
      IF NOT(TO_CHAR(pr_datafinal,'DD') = TO_CHAR(LAST_DAY(pr_datafinal),'DD')) THEN
        IF pr_tab_saldo_projetado.EXISTS(vr_indice - 1) THEN
          -- O Saldo do Juros Remuneratorio será o Saldo da Mensal
          vr_saldo_juros_remuneratorio := pr_tab_saldo_projetado(vr_indice - 1).saldo_projetado + 
                                          pr_tab_saldo_projetado(vr_indice - 1).juros_remuneratorio;
                                          
          -- O Saldo do Juros de Correcao será o Saldo da Mensal
          vr_saldo_juros_correcao      := pr_tab_saldo_projetado(vr_indice - 1).saldo_projetado + 
                                          pr_tab_saldo_projetado(vr_indice - 1).juros_correcao;
        END IF;
      END IF;
      -- Calculo do Juros Remuneratorio
      pr_tab_saldo_projetado(vr_indice).juros_remuneratorio := vr_saldo_juros_remuneratorio * 
                                                               ((POWER(1 + vr_txdiaria,vr_qtdias_corridos))-1);
      -- Calculo do Juros de Correcao
      pr_tab_saldo_projetado(vr_indice).juros_correcao := vr_saldo_juros_correcao * pr_tab_saldo_projetado(vr_indice).taxa_periodo;
      -- Condicao para verificar se devemos calcular o Juros da Parcela
      IF pr_dtvencto IS NOT NULL THEN
        -- Condicao para verificar se jah foi calculado o Juros Total da Parcela
        IF pr_tab_total_juros.EXISTS(pr_nrparepr) THEN
          vr_valor_total_juros := pr_tab_total_juros(pr_nrparepr).valor_total_juros;
        END IF;         
        -- Total do Juros
        pr_tab_total_juros(pr_nrparepr).valor_total_juros := NVL(vr_valor_total_juros,0)  + 
                                                             NVL(pr_tab_saldo_projetado(vr_indice).juros_correcao,0) + 
                                                             NVL(pr_tab_saldo_projetado(vr_indice).juros_remuneratorio,0);
      END IF;                                                 
      --------------------------------------------------------------------------------------------------
      --  Condicao para calcular o saldo projetado
      --------------------------------------------------------------------------------------------------
      IF TO_CHAR(pr_datafinal,'DD') = TO_CHAR(LAST_DAY(pr_datafinal),'DD') THEN
        -- Calculo do saldo devedor projetado
        pr_tab_saldo_projetado(vr_indice).saldo_projetado := vr_saldo_projetado;
      ELSE
        pr_tab_saldo_projetado(vr_indice).saldo_projetado := vr_saldo_projetado + 
                                                             pr_tab_saldo_projetado(vr_indice).juros_correcao + 
                                                             pr_tab_saldo_projetado(vr_indice).juros_remuneratorio;
        
        -- No vencimento da Carencia, precisamos diminuir o valor da parcela no saldo projetado
        IF pr_dtvencto = pr_datafinal THEN
          -- Condicao para verificar se estamos calculando o Valor da Parcela Principal ou Valor da Parcela do Juros da Carencia
          IF pr_vlparepr_principal > 0 THEN
            IF pr_dtvencto >= pr_dtdpagto THEN
              -- Atualiza o Saldo Projetado
              pr_tab_saldo_projetado(vr_indice).saldo_projetado := pr_tab_saldo_projetado(vr_indice).saldo_projetado - 
                                                                   pr_vlparepr_principal;
            END IF;                                                                   
          ELSE
            -- Atualiza o Saldo Projetado
            pr_tab_saldo_projetado(vr_indice).saldo_projetado := pr_tab_saldo_projetado(vr_indice).saldo_projetado - 
                                                                 pr_tab_total_juros(pr_nrparepr).valor_total_juros;            
          END IF;
          
        END IF;
        
        -- Computar o Saldo Projetado + Mensal
        IF pr_tab_saldo_projetado.EXISTS(vr_indice - 1) THEN
          pr_tab_saldo_projetado(vr_indice).saldo_projetado := pr_tab_saldo_projetado(vr_indice).saldo_projetado +
                                                               pr_tab_saldo_projetado(vr_indice - 1).juros_remuneratorio + 
                                                               pr_tab_saldo_projetado(vr_indice - 1).juros_correcao;
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
                                       ,pr_nrdconta        IN  crapepr.nrdconta%TYPE --> Numero da Conta Corrente
                                       ,pr_nrctremp        IN  crapepr.nrctremp%TYPE --> Numero do Contrato
                                       ,pr_dtefetiv        IN  crapepr.dtmvtolt%TYPE --> Data de efetivação da proposta
                                       ,pr_dtdpagto        IN  crawepr.dtdpagto%TYPE --> Data do Primeiro Pagamento
                                       ,pr_txmensal        IN  crapepr.txmensal%TYPE --> Taxa Mensal do Contrato
                                       ,pr_vlrdtaxa        IN  craptxi.vlrdtaxa%TYPE --> Valor da Taxa
                                       ,pr_qtpreemp        IN  crapepr.qtpreemp%TYPE --> Quantidade de Prestacoes do Emprestimo
                                       ,pr_vlsprojt        IN  crapepr.vlsprojt%TYPE --> Saldo Devedor Projetado
                                       ,pr_vlemprst        IN  crawepr.vlemprst%TYPE --> Valor do Emprestimo
                                       ,pr_nrparepr        IN  crappep.nrparepr%TYPE --> Numero da Parcela
                                       ,pr_dtvencto        IN  crappep.dtvencto%TYPE --> Data de Vencimento da Parcela
                                       ,pr_qtdias_carencia IN  tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias de Carencia
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
      -- Cursores
      CURSOR cr_crappep_parcelas(pr_cdcooper IN crappep.cdcooper%TYPE
                                ,pr_nrdconta IN crappep.nrdconta%TYPE
                                ,pr_nrctremp IN crappep.nrctremp%TYPE
                                ,pr_dtvencto IN crappep.dtvencto%TYPE) IS
        SELECT count(*) parcelas
          from crappep
         where cdcooper  = pr_cdcooper
           and nrdconta  = pr_nrdconta
           and nrctremp  = pr_nrctremp
           and dtvencto >= pr_dtvencto
           and inliquid  = 0;
    
      -- Somar os valores corrigidos do valor pago
      CURSOR cr_crappep_saldo_corrigido(pr_cdcooper IN craplem.cdcooper%TYPE
                                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                                       ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT NVL(crappep.vldstcor,0) + NVL(crappep.vldstrem,0) as pago_corrigido
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           and inliquid = 0
           AND vlpagpar > 0;
      vr_vlpagcor            NUMBER(25,2);      
          
      -- Variaveis tratamento de erros
      vr_cdcritic            crapcri.cdcritic%TYPE;
      vr_dscritic            VARCHAR2(4000);
      vr_exc_erro            EXCEPTION;
      
      -- Vetores
      vr_tab_price           typ_tab_price;
      vr_tab_total_juros     typ_tab_total_juros;
      vr_tab_saldo_projetado typ_tab_saldo_projetado;
      
      -- Variaveis
      vr_qtparcel            PLS_INTEGER := 1;
      vr_nrparepr            crappep.nrparepr%TYPE;
      vr_dtvencto            crappep.dtvencto%TYPE;
      vr_datainicial         DATE;
      vr_datafinal           DATE;
      vr_fator_price_total   NUMBER(25,10);
      vr_saldo_projetado     NUMBER(25,2);
      vr_indice              VARCHAR2(10);      
      --vr_qtdmes              number(2);
    BEGIN
      vr_tab_price.DELETE;
      vr_tab_total_juros.DELETE;
      vr_tab_saldo_projetado.DELETE;
      
      -- Numero da parcela inicial
      vr_nrparepr        := pr_nrparepr;
      -- Data da Carencia
      vr_dtvencto        := pr_dtvencto;
      -- Saldo Projetado Inicial
      vr_saldo_projetado := pr_vlsprojt;
      -- Valor Pago Corrigido
      vr_vlpagcor        := 0;
      
      ----------------------------------------------------------------------------------------------------------------
      -- Para o calculo das proximas parcelas, devemos incluir no saldo projeto a correcao dos valores pagos parcial
      ----------------------------------------------------------------------------------------------------------------      
      OPEN cr_crappep_saldo_corrigido(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => pr_nrctremp);	
      FETCH cr_crappep_saldo_corrigido INTO vr_vlpagcor;
      CLOSE cr_crappep_saldo_corrigido;
      -- Incluir no saldo projetado o valor pago corrigido
      vr_saldo_projetado := NVL(vr_saldo_projetado,0) + NVL(vr_vlpagcor,0);
      -- Total de Juros Lancados ate o momento
      vr_tab_total_juros(vr_nrparepr).valor_total_juros := NVL(vr_saldo_projetado,0) - NVL(pr_vlemprst,0);
      -- Data Inicial 
      vr_datainicial := TO_DATE(TO_CHAR(pr_dtvencto,'DD')||'/'||TO_CHAR(pr_dtcalcul,'MM/RRRR'),'DD/MM/RRRR');
      -- Data Final
      vr_datafinal   := LAST_DAY(pr_dtcalcul);
      WHILE vr_datafinal < pr_dtdpagto LOOP
        -- Vencimento da ultima mensal não será calculada 
        IF LAST_DAY(ADD_MONTHS(pr_dtdpagto,-1)) = vr_datafinal THEN
          EXIT;
        END IF;
          
        -- Procedure para calcular o saldo projetado
        pc_calcula_saldo_projetado(pr_cdcooper            => pr_cdcooper
                                  ,pr_flgbatch            => pr_flgbatch
                                  ,pr_dtefetiv            => pr_dtefetiv
                                  ,pr_datainicial         => vr_datainicial
                                  ,pr_datafinal           => vr_datafinal
                                  ,pr_nrparepr            => vr_nrparepr
                                  ,pr_dtvencto            => vr_dtvencto
                                  ,pr_vlrdtaxa            => pr_vlrdtaxa
                                  ,pr_dtdpagto            => pr_dtdpagto
                                  ,pr_txmensal            => pr_txmensal
                                  ,pr_vlsprojt            => vr_saldo_projetado
                                  ,pr_tab_saldo_projetado => vr_tab_saldo_projetado
                                  ,pr_tab_total_juros     => vr_tab_total_juros
                                  ,pr_cdcritic            => vr_cdcritic
                                  ,pr_dscritic            => vr_dscritic);

        -- Condicao para verificar se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
          
        -- Condicao para verificar se devemos calcular o Juros da Carencia
        IF vr_datafinal = vr_dtvencto THEN
          pr_tab_parcelas(vr_nrparepr).nrparepr := vr_nrparepr;
          pr_tab_parcelas(vr_nrparepr).vlparepr := vr_tab_total_juros(vr_nrparepr).valor_total_juros;
          pr_tab_parcelas(vr_nrparepr).vlrdtaxa := pr_vlrdtaxa;
          -- Grava o valor do Juros Correção/Juros Remuneratorio da Parcela
          vr_nrparepr := NVL(vr_nrparepr,0) + 1;
          -- Avanca da data da carencia para o proximo mês
          --PJ298_5
          --vr_qtdmes := pr_qtdias_carencia / 30;
          --vr_dtvencto := ADD_MONTHS(TO_DATE(vr_dtvencto,'DD/MM/RRRR'),vr_qtdmes) ;         
          vr_dtvencto := TO_DATE(TO_CHAR(vr_dtvencto,'DD')||'/'||TO_CHAR(vr_dtvencto + pr_qtdias_carencia,'MM/RRRR'),'DD/MM/RRRR');
        END IF;

        vr_datainicial := vr_datafinal;
        IF TO_CHAR(vr_datafinal,'DD') = TO_CHAR(pr_dtdpagto,'DD') AND vr_datafinal <> LAST_DAY(vr_datafinal) THEN
          vr_datafinal := LAST_DAY(vr_datafinal);
        ELSE
          vr_datafinal := ADD_MONTHS(TO_DATE(TO_CHAR(pr_dtdpagto,'DD')||TO_CHAR(vr_datafinal,'/MM/RRRR'),'DD/MM/RRRR'),1);
        END IF;
      END LOOP;
        
      -- Condicao para verificar se foi possivel calcular o saldo projetado
      IF vr_tab_saldo_projetado.EXISTS(vr_tab_saldo_projetado.last) THEN
        -- Saldo Devedor Projetado que sera a base para o calculo da parcela
        vr_saldo_projetado := vr_tab_saldo_projetado(vr_tab_saldo_projetado.last).saldo_projetado;
      END IF;

      -----------------------------------------------------------------------------------------------------------
      --  REGRAS PARA CALCULAR O VALOR DA PARCELA PRINCIPAL            
      -----------------------------------------------------------------------------------------------------------      
      IF pr_dtdpagto > pr_dtvencto THEN
        vr_qtparcel := pr_qtpreemp;
        vr_dtvencto := pr_dtdpagto;
      ELSE
        -- Total de Parcelas em Aberto
        OPEN cr_crappep_parcelas(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_dtvencto => pr_dtvencto);	
        FETCH cr_crappep_parcelas INTO vr_qtparcel;
        CLOSE cr_crappep_parcelas;
        
        -- Vencimento da proxima parcela
        vr_dtvencto := pr_dtvencto;
      END IF;
      
      -- Calcula o fator price para as parcelas
      pc_calcula_fator_price(pr_cdcooper          => pr_cdcooper
                            ,pr_flgbatch          => pr_flgbatch
                            ,pr_dtefetiv          => pr_dtefetiv
                            ,pr_dtvencto          => vr_dtvencto
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
        pr_tab_parcelas(vr_nrparepr).vlparepr := NVL(vr_saldo_projetado,0) / vr_fator_price_total;
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
                                          ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
  /* .............................................................................

       Programa: pc_calcula_parcelas_pos_fixado
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Abril/2017                         Ultima atualizacao: 08/01/2019

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular as parcelas do Pos-Fixado.
    
       Alteracoes: 12/12/2018 - PRJ298.2 - Permitir a simulacao das parcelas do pos-fixado
			       08/01/2019 - PRJ298.2.2 - Ajustar e validar rotinas respeitando aplicação da varição do indexador - Nagasava (Supero)
    ............................................................................. */
    DECLARE
    -- Busca os dados da linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT txmensal 
              ,cddindex
						,(vlperidx/100) vlperidx
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
      vr_tab_price              typ_tab_price;
      vr_tab_total_juros        typ_tab_total_juros;
      vr_tab_saldo_projetado    typ_tab_saldo_projetado;

      -- Variaveis      
      vr_dtmvtoan               crapdat.dtmvtoan%TYPE;
      vr_dtmvtolt               crapdat.dtmvtolt%TYPE;      
      vr_dtvencto               crappep.dtvencto%TYPE;
      vr_nrparepr               crappep.nrparepr%TYPE;
      vr_dtcarenc               crawepr.dtdpagto%TYPE;
      vr_datainicial            DATE;
      vr_datafinal              DATE;
      vr_fator_price_total      NUMBER(25,10);
      vr_saldo_projetado        NUMBER(25,10);
      vr_indice                 VARCHAR2(4000);
			vr_vlrdtaxa               craptxi.vlrdtaxa%TYPE;
      --vr_qtdmes                 number(2);

      -- Variaveis tratamento de erros
      vr_cdcritic               crapcri.cdcritic%TYPE;
      vr_dscritic               VARCHAR2(4000);
      vr_exc_erro               EXCEPTION;
			--
			rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE;
			--
    BEGIN
			-- Leitura do calendário da cooperativa
			OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
			FETCH btch0001.cr_crapdat INTO rw_crapdat;
	        
			-- Se não encontrar
			IF btch0001.cr_crapdat%NOTFOUND THEN      
				CLOSE btch0001.cr_crapdat;
				-- Montar mensagem de critica
				vr_dscritic := 'Sistema sem data de movimento, tente novamente mais tarde';
				RAISE vr_exc_erro;
			ELSE
				CLOSE btch0001.cr_crapdat;
			END IF;
			--
      vr_tab_price.DELETE;
      vr_tab_total_juros.DELETE;
      vr_tab_saldo_projetado.DELETE;

      vr_dtmvtolt := pr_dtcalcul;
      -- Função para retornar o dia anterior
      vr_dtmvtoan := rw_crapdat.dtmvtoan;

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

			-- Aplica o percentual do indexador sobre o valor da taxa
			vr_vlrdtaxa := (rw_craptxi.vlrdtaxa * rw_craplcr.vlperidx);

      -- Saldo Projetado Inicial
      vr_saldo_projetado := pr_vlemprst;
      -- Percorrer as datas que deverão ser calculadas
      vr_nrparepr        := pr_tab_parcelas.COUNT + 1;      
      -- Data da Carencia
      vr_dtcarenc        := pr_dtcarenc;
      -- Condicao para verificar qual será a data final para fins de calculo (Data do Pagamento ou Ultimo dia do Mes)
      IF TO_NUMBER(TO_CHAR(pr_dtdpagto,'DD')) > TO_NUMBER(TO_CHAR(vr_dtmvtolt,'DD')) THEN
        vr_datafinal := TO_DATE(TO_CHAR(pr_dtdpagto,'DD')||'/'||TO_CHAR(vr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR');
      ELSE
        vr_datafinal := LAST_DAY(vr_dtmvtolt);
                        end if;
      -- Data Inicial será a data de efetivação do contrato
      vr_datainicial := vr_dtmvtolt;
      WHILE vr_datafinal < pr_dtdpagto LOOP
        -- Vencimento da ultima mensal não será calculada 
        IF LAST_DAY(ADD_MONTHS(pr_dtdpagto,-1)) = vr_datafinal THEN
          EXIT;
        end if;
                     
        -- Procedure para calcular o saldo projetado
        pc_calcula_saldo_projetado(pr_cdcooper            => pr_cdcooper
                                  ,pr_flgbatch            => pr_flgbatch
                                  ,pr_dtefetiv            => pr_dtcalcul
                                  ,pr_datainicial         => vr_datainicial
                                  ,pr_datafinal           => vr_datafinal
                                  ,pr_nrparepr            => vr_nrparepr
                                  ,pr_dtvencto            => vr_dtcarenc
                                  ,pr_vlrdtaxa            => vr_vlrdtaxa
                                  ,pr_dtdpagto            => pr_dtdpagto
                                  ,pr_txmensal            => rw_craplcr.txmensal
                                  ,pr_vlsprojt            => pr_vlemprst
                                  ,pr_tab_saldo_projetado => vr_tab_saldo_projetado
                                  ,pr_tab_total_juros     => vr_tab_total_juros
                                  ,pr_cdcritic            => vr_cdcritic
                                  ,pr_dscritic            => vr_dscritic);
                     
        -- Condicao para verificar se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
                  end if;
                  
        -- Condicao para verificar se devemos calcular o Juros da Carencia
        IF vr_datafinal = vr_dtcarenc THEN
          pr_tab_parcelas(vr_nrparepr).nrparepr := vr_nrparepr;
          pr_tab_parcelas(vr_nrparepr).vlparepr := vr_tab_total_juros(vr_nrparepr).valor_total_juros;
          pr_tab_parcelas(vr_nrparepr).dtvencto := vr_dtcarenc;
          pr_tab_parcelas(vr_nrparepr).flcarenc := 1;
          pr_tab_parcelas(vr_nrparepr).vlrdtaxa := vr_vlrdtaxa;
		  pr_tab_parcelas(vr_nrparepr).dtultpag     := NULL;
		  pr_tab_parcelas(vr_nrparepr).insitpar     := 0;
		  pr_tab_parcelas(vr_nrparepr).vlpagpar     := 0;
		  pr_tab_parcelas(vr_nrparepr).vlmtapar     := 0;
		  pr_tab_parcelas(vr_nrparepr).vlmrapar     := 0;
		  pr_tab_parcelas(vr_nrparepr).vliofcpl     := 0;
		  pr_tab_parcelas(vr_nrparepr).vlsdvpar     := 0;
		  pr_tab_parcelas(vr_nrparepr).vldescto     := 0;
		  pr_tab_parcelas(vr_nrparepr).vlpraven     := 0;
		  pr_tab_parcelas(vr_nrparepr).vlatupar     := 0;
		  pr_tab_parcelas(vr_nrparepr).vlatrpag     := 0;
		  pr_tab_parcelas(vr_nrparepr).taxa_periodo := 0;
		  pr_tab_parcelas(vr_nrparepr).vliofpri     := 0;
		  pr_tab_parcelas(vr_nrparepr).vliofadc     := 0;
		  pr_tab_parcelas(vr_nrparepr).vldstcor     := 0;
		  pr_tab_parcelas(vr_nrparepr).vldstcor_atu := 0;
		  pr_tab_parcelas(vr_nrparepr).vldstrem     := 0;
		  pr_tab_parcelas(vr_nrparepr).vldstrem_atu := 0;
		  pr_tab_parcelas(vr_nrparepr).dtdstjur     := NULL;
		  pr_tab_parcelas(vr_nrparepr).inliquid     := NULL;
		  
		  -- Grava o valor do Juros Correção/Juros Remuneratorio da Parcela
          vr_nrparepr := NVL(vr_nrparepr,0) + 1;
          -- Avanca da data da carencia para o proximo mês
          --PJ298_5
          --vr_qtdmes := pr_qtdias_carencia / 30;
          --vr_dtcarenc := ADD_MONTHS(TO_DATE(vr_dtcarenc,'DD/MM/RRRR'),vr_qtdmes); -- Retirar
          vr_dtcarenc := TO_DATE(TO_CHAR(vr_dtcarenc,'DD')||'/'||TO_CHAR(vr_dtcarenc + pr_qtdias_carencia,'MM/RRRR'),'DD/MM/RRRR');
		  --
                END IF;
             
        vr_datainicial := vr_datafinal;
        IF TO_CHAR(vr_datafinal,'DD') = TO_CHAR(pr_dtdpagto,'DD') AND vr_datafinal <> LAST_DAY(vr_datafinal) THEN
          vr_datafinal := LAST_DAY(vr_datafinal);
         else
          vr_datafinal := ADD_MONTHS(TO_DATE(TO_CHAR(pr_dtdpagto,'DD')||TO_CHAR(vr_datafinal,'/MM/RRRR'),'DD/MM/RRRR'),1);
             end if;
      END LOOP;      
             
      -- Condicao para verificar se foi possivel calcular o saldo projetado
      IF vr_tab_saldo_projetado.EXISTS(vr_tab_saldo_projetado.last) THEN
        -- Saldo Devedor Projetado que sera a base para o calculo da parcela
        vr_saldo_projetado := vr_tab_saldo_projetado(vr_tab_saldo_projetado.last).saldo_projetado;
             end if;
             
      -- Procedure para calcular o Fator Price 
      pc_calcula_fator_price(pr_cdcooper          => pr_cdcooper
                            ,pr_flgbatch          => pr_flgbatch
                            ,pr_dtefetiv          => pr_dtcalcul
                            ,pr_dtvencto          => pr_dtdpagto
                            ,pr_txmensal          => rw_craplcr.txmensal
                            ,pr_vlrdtaxa          => vr_vlrdtaxa
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
        vr_dtvencto := pr_dtdpagto;
      IF vr_nrparepr IS NULL OR vr_nrparepr = 0 THEN
        vr_nrparepr := 1;
      ELSE
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
 
	PROCEDURE pc_calc_parc_pos_fixado_prog(pr_cdcooper        IN  crapcop.cdcooper%TYPE                    -- Codigo da Cooperativa
																				,pr_dtcalcul        IN  crapdat.dtmvtolt%TYPE                    -- Data de Calculo
																				,pr_cdlcremp        IN  craplcr.cdlcremp%TYPE                    -- Codigo da Linha de Credito
																				,pr_dtcarenc        IN  crawepr.dtcarenc%TYPE                    -- Data da Carencia do Contrato
																				,pr_qtdias_carencia IN  tbepr_posfix_param_carencia.qtddias%TYPE -- Quantidade de Dias de Carencia
																				,pr_dtdpagto        IN  crapepr.dtdpagto%TYPE                    -- Data de Pagamento
																				,pr_qtpreemp        IN  crapepr.qtpreemp%type                    -- Quantidade de Prestacoes
																				,pr_vlemprst        IN  crapepr.vlemprst%TYPE                    -- Valor do Emprestimo
																				,pr_tab_parcelas    OUT CLOB                                     -- Parcelas do Emprestimo
																				,pr_cdcritic        OUT crapcri.cdcritic%TYPE                    -- Codigo da critica
																				,pr_dscritic        OUT crapcri.dscritic%TYPE                    -- Descricao da critica
		                                    ) IS
	  /* .............................................................................

       Programa: pc_calc_parc_pos_fixado_prog
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Adriano Nagasava (Supero)
       Data    : Dezembro/2018                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular as parcelas do Pos-Fixado e retorna-las para o progress.
    
       Alteracoes: 
			 
    ............................................................................. */
		--
		vr_tab_parcelas typ_tab_parcelas;
		--
		vr_dstexto      VARCHAR2(32767);
    vr_string       VARCHAR2(32767);
		vr_index        VARCHAR(24);
		--
	BEGIN
		--
		empr0011.pc_calcula_parcelas_pos_fixado(pr_cdcooper        => pr_cdcooper
		                                       ,pr_dtcalcul        => pr_dtcalcul
																					 ,pr_cdlcremp        => pr_cdlcremp
																					 ,pr_dtcarenc        => pr_dtcarenc
																					 ,pr_qtdias_carencia => pr_qtdias_carencia
																					 ,pr_dtdpagto        => pr_dtdpagto
																					 ,pr_qtpreemp        => pr_qtpreemp
																					 ,pr_vlemprst        => pr_vlemprst
																					 ,pr_tab_parcelas    => vr_tab_parcelas
																					 ,pr_cdcritic        => pr_cdcritic
																					 ,pr_dscritic        => pr_dscritic
																					 );
		-- Montar CLOB
		IF vr_tab_parcelas.COUNT > 0 THEN
        
			-- Criar documento XML
			dbms_lob.createtemporary(pr_tab_parcelas, TRUE); 
			dbms_lob.open(pr_tab_parcelas, dbms_lob.lob_readwrite);
        
			-- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml            => pr_tab_parcelas 
														 ,pr_texto_completo => vr_dstexto 
														 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>'
														 );
         
			--Buscar Primeiro beneficiario
			vr_index:= vr_tab_parcelas.FIRST;
        
			--Percorrer todos os beneficiarios
			WHILE vr_index IS NOT NULL LOOP
				vr_string := '<parcela>'        ||
											 '<nrparepr>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).nrparepr),' ')              || '</nrparepr>'     ||
											 '<vlparepr>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vlparepr),' ')              || '</vlparepr>'     ||
											 '<dtvencto>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).dtvencto,'DD/MM/YYYY'),' ') || '</dtvencto>'     ||
											 '<dtultpag>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).dtultpag,'DD/MM/YYYY'),' ') || '</dtultpag>'     ||
											 '<insitpar>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).insitpar),' ')              || '</insitpar>'     ||
											 '<vlpagpar>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vlpagpar),' ')              || '</vlpagpar>'     ||
											 '<vlmtapar>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vlmtapar),' ')              || '</vlmtapar>'     ||
											 '<vlmrapar>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vlmrapar),' ')              || '</vlmrapar>'     ||
											 '<vliofcpl>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vliofcpl),' ')              || '</vliofcpl>'     ||
											 '<vlsdvpar>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vlsdvpar),' ')              || '</vlsdvpar>'     ||
											 '<vldescto>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vldescto),' ')              || '</vldescto>'     ||
											 '<vlpraven>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vlpraven),' ')              || '</vlpraven>'     ||
											 '<vlatupar>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vlatupar),' ')              || '</vlatupar>'     ||
											 '<vlatrpag>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vlatrpag),' ')              || '</vlatrpag>'     ||
											 '<flcarenc>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).flcarenc),' ')              || '</flcarenc>'     ||
											 '<vlrdtaxa>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vlrdtaxa),' ')              || '</vlrdtaxa>'     ||
											 '<taxa_periodo>' || NVL(TO_CHAR(vr_tab_parcelas(vr_index).taxa_periodo),' ')          || '</taxa_periodo>' ||
											 '<vliofpri>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vliofpri),' ')              || '</vliofpri>'     ||
											 '<vliofadc>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vliofadc),' ')              || '</vliofadc>'     ||
											 '<vldstcor>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vldstcor),' ')              || '</vldstcor>'     ||
											 '<vldstcor_atu>' || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vldstcor_atu),' ')          || '</vldstcor_atu>' ||
											 '<vldstrem>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vldstrem),' ')              || '</vldstrem>'     ||
											 '<vldstrem_atu>' || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vldstrem_atu),' ')          || '</vldstrem_atu>' ||
											 '<dtdstjur>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).dtdstjur,'DD/MM/YYYY'),' ') || '</dtdstjur>'     ||
										 '</parcela>';

				-- Escrever no XML
				gene0002.pc_escreve_xml(pr_xml            => pr_tab_parcelas 
															 ,pr_texto_completo => vr_dstexto 
															 ,pr_texto_novo     => vr_string
															 ,pr_fecha_xml      => FALSE
															 );   
                                                    
				--Proximo Registro
				vr_index:= vr_tab_parcelas.NEXT(vr_index);
          
			END LOOP;  
        
			-- Encerrar a tag raiz 
			gene0002.pc_escreve_xml(pr_xml            => pr_tab_parcelas 
														 ,pr_texto_completo => vr_dstexto 
														 ,pr_texto_novo     => '</root>' 
														 ,pr_fecha_xml      => TRUE
														 );
                               
		END IF;
		--
	EXCEPTION
		WHEN OTHERS THEN
			pr_dscritic := SQLERRM;
	END pc_calc_parc_pos_fixado_prog;
 
  PROCEDURE pc_calcula_atraso_pos_fixado (pr_cdcooper IN  crappep.cdcooper%TYPE   --> Codigo da Cooperativa
                                         ,pr_cdprogra IN  crapprg.cdprogra%TYPE   --> Codigo do Programa
                                         ,pr_nrdconta IN  crappep.nrdconta%TYPE   --> Numero da Conta Corrente
                                         ,pr_nrctremp IN  crappep.nrctremp%TYPE   --> Numero do Contrato
                                         ,pr_cdlcremp IN  crapepr.cdlcremp%TYPE   --> Linha de Credito
                                         ,pr_dtcalcul IN  crapdat.dtmvtolt%TYPE   --> Data de Calculo
                                         ,pr_vlemprst IN  crapepr.vlemprst%TYPE   --> Valor do Emprestimo 
                                         ,pr_nrparepr IN  crappep.nrparepr%TYPE   --> Numero da Parcela do Emprestimo
                                         ,pr_vlparepr IN  crappep.vlparepr%TYPE   --> Valor da Parcela
                                         ,pr_dtvencto IN  crappep.dtvencto%TYPE   --> Data de Vencimento da Parcela
                                         ,pr_dtultpag IN  crappep.dtultpag%TYPE   --> Data do Ultimo Pagamento
                                         ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE   --> Saldo Devedor da Parcela
                                         ,pr_perjurmo IN  craplcr.perjurmo%TYPE   --> Percentual do Juros de Mora
                                         ,pr_vlpagmta IN  crappep.vlpagmta%TYPE   --> Valor Pago de Mula
                                         ,pr_percmult IN  NUMBER                  --> Percentual de Multa
                                         ,pr_txmensal IN  crapepr.txmensal%TYPE   --> Taxa mensal do Emprestimo
                                         ,pr_qttolatr IN  crapepr.qttolatr%TYPE   --> Quantidade de Tolerancia para Cobrar Multa/Juros de Mora
                                         ,pr_vlmrapar OUT NUMBER                  --> Juros de Mora Atualizado
                                         ,pr_vlmtapar OUT NUMBER                  --> Multa Atualizado
                                         ,pr_vliofcpl OUT NUMBER                  --> IOF Complementar em Atraso
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo da critica
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    /* .............................................................................
       Programa: pc_calcula_atraso_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Junho/2017                         Ultima atualizacao: 10/05/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o valor de desconto da parcela

       Alteracoes: 10/05/2018 - P410 - Ajuste IOF (Marcos - Envolti)
    ............................................................................. */    
    DECLARE
      -- Buscar dados do contrato
      CURSOR cr_crawepr(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT cdfinemp
          FROM crawepr 
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;     
    
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE
                       ,pr_nrparepr IN craplem.nrparepr%TYPE) IS
        SELECT SUM(vllanmto) vllanmto
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND nrparepr = pr_nrparepr
           AND cdhistor IN (2343,2342,2345,2344);
      vr_vllanmto     craplem.vllanmto%TYPE;  
    
      -- Variaveis de calculo
      vr_qtdiamor     PLS_INTEGER;
      vr_qtdiamul     PLS_INTEGER;
      vr_txdiaria     NUMBER(25,7);
      vr_percmult     NUMBER(25,2);
      vr_dtjurmora    DATE;
      vr_vliofpri     NUMBER(25,2);
      vr_vliofadi     NUMBER(25,2);
      vr_vltxaiof     tbgen_iof_taxa.vltaxa_iof%TYPE;
      vr_flgimune     PLS_INTEGER;
      vr_vlparcela_sem_juros NUMBER(25,2);
      vr_vlbaseiof    NUMBER(25,2);
      
      -- Variaveis tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      vr_exc_erro     EXCEPTION;
    BEGIN
      -- Buscar dados do contrato
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr
       INTO rw_crawepr;
      CLOSE cr_crawepr; 
    
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
      
      -- Quantidade de dias em atraso para Mora e IOF
      vr_qtdiamor := pr_dtcalcul - vr_dtjurmora;
      -- Se a quantidade de dias está dentro da tolerancia de juros de mora
      IF vr_qtdiamor <= pr_qttolatr THEN
        -- Zerar o percentual de mora
        pr_vlmrapar := 0;
      ELSE
        -- Taxa de mora recebe o valor da linha de crédito
        vr_txdiaria := ROUND((100 * (POWER(((pr_perjurmo + pr_txmensal) / 100) + 1,(1 / 30)) - 1)),7);
        -- Valor de juros de mora é relativo ao juros sem inadimplencia da parcela + taxa diaria calculada + quantidade de dias de mora
        pr_vlmrapar := round((pr_vlsdvpar * (vr_txdiaria / 100) * vr_qtdiamor),2);
      END IF;		
      --------------------------------------------------------------------------------------------------------------
      --                                  FIM PARA CALCULAR O VALOR DO JUROS DE MORA
      --------------------------------------------------------------------------------------------------------------
	  
	    --------------------------------------------------------------------------------------------------------------
   	  --                                     CALCULO IOF COMPLEMENTAR ATRASO                                      --
	    --------------------------------------------------------------------------------------------------------------
      vr_vllanmto := 0;
      OPEN cr_craplem(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrparepr => pr_nrparepr);
      FETCH cr_craplem INTO vr_vllanmto;
      CLOSE cr_craplem;      
      -- Valor da Parcela sem o Juros
      vr_vlparcela_sem_juros := NVL(pr_vlparepr,0) - NVL(vr_vllanmto,0);
      
      -- BAse do IOF Complementar é o menor valor entre o Saldo Devedor ou O Principal
      vr_vlbaseiof := LEAST(vr_vlparcela_sem_juros,pr_vlsdvpar);
      
      -- Calcula o valor da do IOF e tarifa
      TIOF0001.pc_calcula_valor_iof_epr(pr_tpoperac => 2 --> Somente atraso
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_vlemprst => vr_vlbaseiof
                                       ,pr_vltotope => pr_vlemprst
                                       ,pr_dscatbem => ''
                                       ,pr_cdfinemp => rw_crawepr.cdfinemp
                                       ,pr_cdlcremp => pr_cdlcremp
                                       ,pr_dtmvtolt => pr_dtcalcul
                                       ,pr_qtdiaiof => vr_qtdiamor                                       
                                       ,pr_vliofpri => vr_vliofpri
                                       ,pr_vliofadi => vr_vliofadi
                                       ,pr_vliofcpl => pr_vliofcpl
                                       ,pr_vltaxa_iof_principal => vr_vltxaiof
                                       ,pr_flgimune => vr_flgimune
                                       ,pr_dscritic => vr_dscritic);
                                       
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
   		-------------------------------------------------------------------------------------------------------------
      --                 FIM CALCULO IOF COMPLEMENTAR ATRASO                                                     --
      -------------------------------------------------------------------------------------------------------------		
	  
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
  
  PROCEDURE pc_calcula_desconto_pos(pr_dtcalcul  IN  crapdat.dtmvtolt%TYPE --> Data do cálculo
                                   ,pr_flgbatch  IN  BOOLEAN DEFAULT FALSE --> Indica se o processo noturno estah rodando
                                   ,pr_cdcooper  IN  crapepr.cdcooper%TYPE --> Codigo da Cooperativa
                                   ,pr_dtefetiv  IN  crapepr.dtmvtolt%TYPE --> Data de Efetivacao do Contrato
                                   ,pr_txmensal  IN  crawepr.txmensal%TYPE --> Taxa Mensal do Emprestimo
                                   ,pr_dtdpagto  IN  crawepr.dtdpagto%TYPE --> Data de Pagamento da Proposta
                                   ,pr_vlsprojt  IN  crapepr.vlsprojt%TYPE --> Saldo Projetoado do contrato
                                   ,pr_nrparepr  in  crappep.nrparepr%TYPE --> Numero da Parcela
                                   ,pr_dtvencto  IN  crappep.dtvencto%TYPE --> Data de Vencimento da Parcela
                                   ,pr_vlsdvpar  IN  crappep.vlsdvpar%TYPE --> Saldo Devedor da Parcela
                                   ,pr_vltaxatu  IN  crappep.vltaxatu%TYPE --> Taxa do CDI da parcela
                                   ,pr_tab_price IN OUT typ_tab_price      --> Temp-Table 
                                   ,pr_vlatupar  OUT NUMBER                --> Valor Atualizado da Parcela
                                   ,pr_vldescto  OUT NUMBER                --> Valor de Desconto da Parcela
                                   ,pr_cdcritic  OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                   ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
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
      -- Variaveis
      vr_qtparcel              PLS_INTEGER;
      vr_fator_price_total     NUMBER(25,10);      
      vr_vlpresente_liquido    NUMBER(25,2);
      vr_total_juros           NUMBER(25,2);
      vr_datainicial           DATE;
      vr_datafinal             DATE;
      vr_dtvencto              crappep.dtvencto%TYPE;
      
      -- Temp-Table
      vr_tab_saldo_projetado   typ_tab_saldo_projetado;
      vr_tab_total_juros       typ_tab_total_juros;
      
      -- Variaveis tratamento de erros
      vr_cdcritic              crapcri.cdcritic%TYPE;
      vr_dscritic              VARCHAR2(4000);
      vr_exc_erro              EXCEPTION;
    BEGIN
      vr_tab_saldo_projetado.DELETE;
      vr_tab_total_juros.DELETE;

      -- Condicao para verificar se estah sendo calculado o Juros da Carencia
      IF pr_dtdpagto > pr_dtvencto THEN
        pr_vlatupar := NVL(pr_vlsdvpar,0);
        pr_vldescto := 0;
        RETURN;
      END IF;
      
      -- Condicao para verificar se estamos calculando a parcela principal
      IF pr_tab_price.COUNT > 0 THEN
        vr_qtparcel := pr_tab_price.COUNT + 1;
        vr_dtvencto := pr_dtvencto;
      ELSE 
        vr_qtparcel := months_between(trunc(pr_dtvencto,'MM'),trunc(pr_dtcalcul,'MM'));  
        IF TO_NUMBER(TO_CHAR(pr_dtcalcul,'DD')) < TO_NUMBER(TO_CHAR(pr_dtvencto,'DD')) THEN
          vr_qtparcel := vr_qtparcel + 1;
        END IF;
        IF NVL(vr_qtparcel,0) = 0 THEN
          vr_qtparcel := 1;          
        END IF;
          
        vr_dtvencto := TO_DATE(TO_CHAR(pr_dtvencto,'DD')||'/'||TO_CHAR(pr_dtcalcul,'MM/RRRR'),'DD/MM/RRRR');
        -- Condicao para verificar se o dia atual eh maior que o dia do vencimento
        IF TO_NUMBER(TO_CHAR(pr_dtcalcul,'DD')) >= TO_NUMBER(TO_CHAR(vr_dtvencto,'DD')) THEN
          vr_dtvencto := ADD_MONTHS(vr_dtvencto,1);
        END IF;        
      END IF;
      
      -- Rotina para calcular o price da parcela que sera antecipada
      pc_calcula_fator_price(pr_cdcooper          => pr_cdcooper
                            ,pr_flgbatch          => pr_flgbatch
                            ,pr_dtefetiv          => pr_dtefetiv
                            ,pr_dtvencto          => vr_dtvencto
                            ,pr_txmensal          => pr_txmensal
                            ,pr_vlrdtaxa          => pr_vltaxatu
                            ,pr_qtparcel          => vr_qtparcel
                            ,pr_tab_price         => pr_tab_price
                            ,pr_fator_price_total => vr_fator_price_total
                            ,pr_cdcritic          => vr_cdcritic
                            ,pr_dscritic          => vr_dscritic);
                                  
      -- Condicao para verificar se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
          
      -- Condicao para verificar se foi calculado o fator price
      IF NOT pr_tab_price.EXISTS(pr_tab_price.FIRST) THEN
        vr_dscritic := 'Nao foi possivel calcular o fator price'; 
        RAISE vr_exc_erro;
      END IF;
          
      -- Calculo do Valor Presente Liquido
      vr_vlpresente_liquido := pr_vlsdvpar / pr_tab_price(pr_tab_price.last).fator_acumulado;
    
      ---------------------------------------------------------------------------------------------------------
      --                          INICIO - Calcular Juros Remuneratorio/Correcao
      ---------------------------------------------------------------------------------------------------------      
      ---------------------------------------------------------------------------------------------------------
      -- Regra para definir qual data de inicio sera para calcular Juros
      ---------------------------------------------------------------------------------------------------------
      vr_datainicial := TO_DATE(TO_CHAR(pr_dtvencto,'DD')||'/'||TO_CHAR(pr_dtcalcul,'MM/RRRR'),'DD/MM/RRRR');
      IF vr_datainicial >= pr_dtcalcul THEN
        vr_datainicial := ADD_MONTHS(vr_datainicial,-1);
      END IF;
      
      IF pr_dtefetiv > vr_datainicial THEN
        vr_datainicial := pr_dtefetiv;
      END IF;
      
      ---------------------------------------------------------------------------------------------------------
      -- Regra para definir qual data final sera para calcular Juros
      ---------------------------------------------------------------------------------------------------------      
      vr_datafinal := pr_dtcalcul;
      IF TO_CHAR(vr_datainicial,'MMRRRR') <> TO_CHAR(vr_datafinal,'MMRRRR') THEN
        vr_datafinal := LAST_DAY(vr_datainicial);
      END IF;
      
      ---------------------------------------------------------------------------------------------------------
      -- Regra para definir qual data final sera para calcular Juros
      ---------------------------------------------------------------------------------------------------------            
      WHILE vr_datainicial < pr_dtcalcul LOOP
        -- Procedure para calcular o saldo projetado
        pc_calcula_saldo_projetado(pr_cdcooper            => pr_cdcooper
                                  ,pr_flgbatch            => pr_flgbatch
                                  ,pr_dtefetiv            => pr_dtefetiv
                                  ,pr_datainicial         => vr_datainicial
                                  ,pr_datafinal           => vr_datafinal
                                  ,pr_nrparepr            => pr_nrparepr
                                  ,pr_dtvencto            => pr_dtvencto
                                  ,pr_vlrdtaxa            => pr_vltaxatu
                                  ,pr_dtdpagto            => pr_dtvencto
                                  ,pr_txmensal            => pr_txmensal
                                  ,pr_vlsprojt            => vr_vlpresente_liquido
                                  ,pr_tab_saldo_projetado => vr_tab_saldo_projetado
                                  ,pr_tab_total_juros     => vr_tab_total_juros
                                  ,pr_cdcritic            => vr_cdcritic
                                  ,pr_dscritic            => vr_dscritic);

        -- Condicao para verificar se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Valor da Parcela + Juros de Correcao + Juros Remuneratorio
        vr_total_juros := NVL(vr_total_juros,0) + 
                          NVL(vr_tab_saldo_projetado(vr_tab_saldo_projetado.LAST).juros_correcao,0) +
                          NVL(vr_tab_saldo_projetado(vr_tab_saldo_projetado.LAST).juros_remuneratorio,0);

        vr_datainicial := vr_datafinal;
        vr_datafinal   := pr_dtcalcul;
      END LOOP;
      ---------------------------------------------------------------------------------------------------------
      --                          FIM - Calcular Juros Remuneratorio/Correcao
      ---------------------------------------------------------------------------------------------------------            
      -- Valor Atualizado da Parcela
      pr_vlatupar := NVL(vr_vlpresente_liquido,0) + NVL(vr_total_juros,0);
      -- Valor de desconto
      pr_vldescto := NVL(pr_vlsdvpar,0) - NVL(pr_vlatupar,0);      
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

  PROCEDURE pc_calcula_descto_pos_parcial(pr_cdcooper   IN crappep.cdcooper%TYPE --> Codigo da Cooperativa
                                         ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                         ,pr_nrdconta   IN crappep.nrdconta%TYPE --> Numero da Conta Corrente
                                         ,pr_nrctremp   IN crappep.nrctremp%TYPE --> Numero do Contrato
                                         ,pr_nrparepr   IN crappep.nrparepr%TYPE --> Numero da Parcela do Emprestimo
                                         ,pr_vlpagpar   IN crappep.vlpagpar%TYPE --> Valor pago da Parcela
                                         ,pr_vldescto  OUT NUMBER                --> Valor de Desconto da Parcela
                                         ,pr_cdcritic  OUT crapcri.cdcritic%TYPE --> Codigo da critica
                                         ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
  BEGIN
    /* .............................................................................
       Programa: pc_calcula_descto_pos_parcial
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Junho/2017                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o valor de desconto da parcela parcial

       Alteracoes: 
    ............................................................................. */
    
    DECLARE
      -- Cursor de emprestimo
      CURSOR cr_crapepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT crapepr.cdlcremp
              ,crapepr.dtmvtolt
              ,crapepr.vlsprojt
              ,crawepr.dtdpagto
              ,crapepr.txmensal
          FROM crapepr
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      -- Cursor das Parcelas
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE
                       ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT crappep.nrparepr
              ,crappep.dtvencto
              ,crappep.vlsdvpar
              ,crappep.vltaxatu
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      
      -- Variaveis para calcula da parcela
      vr_txdiaria              craplcr.txdiaria%TYPE;
      vr_blnachou              BOOLEAN;
      vr_data_inicial          DATE;
      vr_data_final            DATE;
      vr_qtdia_corridos        PLS_INTEGER;
      vr_qtdia_uteis           PLS_INTEGER;
      vr_vldescto_remunert     NUMBER(25,2);
      vr_vldescto_correcao     NUMBER(25,2);
      vr_vlpagpar              crappep.vlpagpar%TYPE;
      vr_vlatupar              NUMBER(25,2);
      
      -- Vetores
      vr_tab_price             typ_tab_price;
      
      -- Variaveis tratamento de erros
      vr_cdcritic              crapcri.cdcritic%TYPE;
      vr_dscritic              VARCHAR2(4000);
      vr_exc_erro              EXCEPTION;
    BEGIN
      vr_tab_price.DELETE;
      
      -- Buscar os dados de emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
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
    
      -- Buscar os dados de emprestimo
      OPEN cr_crappep(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrparepr => pr_nrparepr);
      FETCH cr_crappep INTO rw_crappep;
      vr_blnachou := cr_crappep%FOUND;
      CLOSE cr_crappep;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_dscritic := 'Parcela ' || pr_nrparepr + ' nao encontrada.';
        RAISE vr_exc_erro;
      END IF;
      
      ---------------------------------------------------------------------------------------------------------------
      -- Regra definida pela Franciele/Suzana
      -- 
      -- Se o valor informado for igual ao valor da parcela, deverá calcular o desconto como total
      -- Se o valor informado for diferente do valor da parcela, devera aplicar o calculo proporcional ao valor pago
      ---------------------------------------------------------------------------------------------------------------
      IF pr_vlpagpar = rw_crappep.vlsdvpar THEN
        -- Calcula o desconto da parcela
        EMPR0011.pc_calcula_desconto_pos(pr_dtcalcul  => pr_dtmvtolt
                                        ,pr_flgbatch  => FALSE
                                        ,pr_cdcooper  => pr_cdcooper
                                        ,pr_dtefetiv  => rw_crapepr.dtmvtolt
                                        ,pr_txmensal  => rw_crapepr.txmensal
                                        ,pr_dtdpagto  => rw_crapepr.dtdpagto
                                        ,pr_vlsprojt  => rw_crapepr.vlsprojt
                                        ,pr_nrparepr  => rw_crappep.nrparepr
                                        ,pr_dtvencto  => rw_crappep.dtvencto
                                        ,pr_vlsdvpar  => rw_crappep.vlsdvpar
                                        ,pr_vltaxatu  => rw_crappep.vltaxatu
                                        ,pr_tab_price => vr_tab_price
                                        ,pr_vlatupar  => vr_vlatupar
                                        ,pr_vldescto  => pr_vldescto
                                        ,pr_cdcritic  => vr_cdcritic
                                        ,pr_dscritic  => vr_dscritic);
          
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
          
      ELSE
        -- Valor Pago da Parcela
        vr_vlpagpar     := pr_vlpagpar;
        -- Calculo da Taxa Diaria
        vr_txdiaria     := POWER(1 + (NVL(rw_crapepr.txmensal,0) / 100),(1 / 30)) - 1;
        -- Data de Inicio sera a data de movimento
        vr_data_inicial := pr_dtmvtolt;
        -- Data Final sera o vencimento da parcela do proximo mes
        vr_data_final   := ADD_MONTHS(TO_DATE(TO_CHAR(rw_crappep.dtvencto,'DD')||'/'||TO_CHAR(vr_data_inicial,'MM/RRRR'),'DD/MM/RRRR'),1);
        -- Percorrer a       
        WHILE vr_data_inicial < rw_crappep.dtvencto LOOP
          -- Quantidade de dias para o calculo
          pc_calcula_dias360(pr_ehmensal   => FALSE
                            ,pr_dtvencto   => rw_crappep.dtvencto
                            ,pr_dtrefjur   => vr_data_inicial
                            ,pr_data_final => vr_data_final
                            ,pr_qtdedias   => vr_qtdia_corridos
                            ,pr_cdcritic   => vr_cdcritic
                            ,pr_dscritic   => vr_dscritic);
                            
          -- Condicao para verificar se houve critica
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Quantidade de dias para o calculo
          pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper
                                   ,pr_flgbatch    => FALSE
                                   ,pr_dtefetiv    => rw_crapepr.dtmvtolt
                                   ,pr_datainicial => vr_data_inicial
                                   ,pr_datafinal   => vr_data_final
                                   ,pr_qtdiaute    => vr_qtdia_uteis
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);
          -- Condicao para verificar se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Correção do Juros Remuneratorio
          vr_vldescto_remunert := NVL(vr_vlpagpar,0) * (POWER(1 + vr_txdiaria,vr_qtdia_corridos) - 1);
          -- Correção do Juros de Correção
          vr_vldescto_correcao := NVL(vr_vlpagpar,0) * (POWER(1 + (rw_crappep.vltaxatu / 100),vr_qtdia_uteis / 252) - 1);
          -- Valor Total Pago
          vr_vlpagpar          := NVL(vr_vlpagpar,0) + NVL(vr_vldescto_remunert,0) + NVL(vr_vldescto_correcao,0);
          -- Valor Total do Desconto
          pr_vldescto          := NVL(pr_vldescto,0) + NVL(vr_vldescto_remunert,0) + NVL(vr_vldescto_correcao,0);
          -- Incrementa a data de vencimento para o proximo mes
          vr_data_inicial := vr_data_final;
          vr_data_final   := ADD_MONTHS(vr_data_final,1);
        END LOOP;
        
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
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_descto_pos_parcial: ' || SQLERRM;
    END;

  END pc_calcula_descto_pos_parcial;

  PROCEDURE pc_calcula_desconto_pos_web(pr_dtmvtolt     IN VARCHAR2              --> Data de Movimento Atual
                                       ,pr_dtmvtoan     IN VARCHAR2              --> Data de Movimento Anterior
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
      -- Cursor de emprestimo
      CURSOR cr_crapepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT crapepr.dtmvtolt
              ,crawepr.txmensal
              ,crawepr.cddindex
              ,crawepr.dtdpagto
              ,crapepr.vlsprojt
          FROM crapepr
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      -- Cursor da parcelas dos Emprestimo
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE
                       ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT crappep.vltaxatu
              ,crappep.vlpagpar
              ,crappep.dtvencto
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      
      -- Variaveis gerais
      vr_vlatupar  NUMBER;
      vr_vldescto  NUMBER;
      vr_blnachou  BOOLEAN;
      vr_dtmvtolt  crapdat.dtmvtolt%TYPE;     
      vr_tab_price typ_tab_price;

      -- Variaveis tratamento de erros
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      vr_exc_erro  EXCEPTION;

    BEGIN
      vr_tab_price.DELETE;
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_calcula_desconto_pos_web'
                                ,pr_action => NULL);

      -- Converte para data
      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/RRRR');
      
     	-- Buscar os dados de emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
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
      
      -- Buscar os dados de emprestimo
      OPEN cr_crappep(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrparepr => pr_nrparepr);
      FETCH cr_crappep INTO rw_crappep;
      vr_blnachou := cr_crappep%FOUND;
      CLOSE cr_crappep;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_dscritic := 'Parcela ' || pr_nrparepr + ' nao encontrada.';
        RAISE vr_exc_erro;
      END IF;  	
      
      -- Calculo do desconto parcial
      pc_calcula_descto_pos_parcial(pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                   ,pr_dtmvtolt => vr_dtmvtolt -- Data de Movimento
                                   ,pr_nrdconta => pr_nrdconta -- Numero da Conta Corrente
                                   ,pr_nrctremp => pr_nrctremp -- Numero do Contrato
                                   ,pr_nrparepr => pr_nrparepr -- Parcela
                                   ,pr_vlpagpar => pr_vlsdvpar -- Valor Pago Parcela
                                   ,pr_vldescto => vr_vldescto -- Desconto da Parcela
                                   ,pr_cdcritic => vr_cdcritic -- Codigo da Critica
                                   ,pr_dscritic => vr_dscritic);
      
      -- Condicao para verificar se houve erro
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

  PROCEDURE pc_calcula_juros_remuneratorio(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                          ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento do Dia Anterior
                                          ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual                                      
                                          ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                          ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                          ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de Liberacao do Contrato
                                          ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                  	      ,pr_insitpar IN  PLS_INTEGER DEFAULT NULL  --> Situacao da Parcela
                                          ,pr_vlsprojt IN  crapepr.vlsdeved%TYPE     --> Valor do Saldo Devedor Projetado
                                          ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando na mensal
                                          ,pr_txdiaria IN  NUMBER                    --> Taxa Diaria do Contrato
                                          ,pr_diarefju IN OUT crapepr.diarefju%TYPE  --> Dia de Referencia de Juros
                                          ,pr_mesrefju IN OUT crapepr.mesrefju%TYPE  --> Mes de Referencia do Juros
                                          ,pr_anorefju IN OUT crapepr.anorefju%TYPE  --> Ano de Referencia do Juros
                                          ,pr_vljuremu OUT NUMBER                    --> Juros Remuneratorios
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................
       Programa: pc_calcula_juros_remuneratorio
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Junho/2017                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o Juros Remuneratorio

       Alteracoes: 
    ............................................................................. */
    
    DECLARE
      -- Somar os lançamentos de Juros Remuneratorio
      CURSOR cr_craplem_juros(pr_cdcooper IN craplem.cdcooper%TYPE
                             ,pr_nrdconta IN craplem.nrdconta%TYPE
                             ,pr_nrctremp IN craplem.nrctremp%TYPE
                             ,pr_dtinicio IN DATE
                             ,pr_dtfim    IN DATE) IS
        SELECT SUM(vllanmto) vllanmto
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND cdhistor IN (2342,2343)
           AND dtmvtolt >  pr_dtinicio 
           AND dtmvtolt <= pr_dtfim;
      
      -- Somar todos os lancamentos de pagamento de antecipacao Total
      CURSOR cr_craplem_pago_total(pr_cdcooper IN craplem.cdcooper%TYPE
                                  ,pr_nrdconta IN craplem.nrdconta%TYPE
                                  ,pr_nrctremp IN craplem.nrctremp%TYPE
                                  ,pr_dtinicio IN DATE
                                  ,pr_dtfim    IN DATE) IS
        SELECT SUM(craplem.vllanmto) vllanmto
          FROM craplem
          join crappep
            on crappep.cdcooper = craplem.cdcooper
           and crappep.nrdconta = craplem.nrdconta
           and crappep.nrctremp = craplem.nrctremp
           and crappep.nrparepr = craplem.nrparepr
           and crappep.vldespar > 0
           and crappep.inliquid = 1
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor IN (2331,2330,2335,2334)
           AND craplem.dtmvtolt >  pr_dtinicio 
           AND craplem.dtmvtolt <= pr_dtfim;     
      
      -- Somar todos os lancamentos de pagamento de antecipacao
      CURSOR cr_craplem_pago_parcial(pr_cdcooper IN craplem.cdcooper%TYPE
                                    ,pr_nrdconta IN craplem.nrdconta%TYPE
                                    ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT SUM(craplem.vllanmto) vllanmto
          FROM craplem
          join crappep
            on crappep.cdcooper = craplem.cdcooper
           and crappep.nrdconta = craplem.nrdconta
           and crappep.nrctremp = craplem.nrctremp
           and crappep.nrparepr = craplem.nrparepr
           and crappep.vldespar > 0
           and crappep.inliquid = 0
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor IN (2331,2330,2335,2334);    
                 
      -- Variaveis de calculo da procedure
      vr_diavtolt              INTEGER;
      vr_mesvtolt              INTEGER;
      vr_anovtolt              INTEGER;
      vr_qtdedias              PLS_INTEGER;
      vr_vljuros_mensal        craplem.vllanmto%TYPE := 0;
      vr_data_final            DATE;
      vr_dtvencto_calc         DATE;
      vr_vlpago_total          NUMBER(25,2);
      vr_vlpago_parcial        NUMBER(25,2);         
    
      -- Variaveis tratamento de erros
      vr_cdcritic              crapcri.cdcritic%TYPE;
    BEGIN
      -- Logica para encontrar a data inicial para calculo
      IF pr_diarefju <> 0 AND pr_mesrefju <> 0 AND pr_anorefju <> 0 THEN
        vr_diavtolt := pr_diarefju;
        vr_mesvtolt := pr_mesrefju;
        vr_anovtolt := pr_anorefju;     
      ELSE
        vr_diavtolt := to_number(to_char(pr_dtlibera, 'DD'));
        vr_mesvtolt := to_number(to_char(pr_dtlibera, 'MM'));
        vr_anovtolt := to_number(to_char(pr_dtlibera, 'YYYY'));
      END IF;  
      
      -- Parcela em Dia
      IF pr_insitpar = 1 THEN
        vr_data_final := pr_dtvencto;
      -- Parcela a Vencer  
      ELSIF pr_insitpar = 3 THEN
        vr_data_final := pr_dtmvtolt;
      -- Mensal  
      ELSIF pr_ehmensal THEN
        vr_data_final := last_day(pr_dtmvtolt);
      END IF;
      
      --Retornar Dia/mes/ano de referencia
      pr_diarefju := to_number(to_char(vr_data_final, 'DD'));
      pr_mesrefju := to_number(to_char(vr_data_final, 'MM'));
      pr_anorefju := to_number(to_char(vr_data_final, 'YYYY'));        
      
      EMPR0001.pc_calc_dias360(pr_ehmensal => pr_ehmensal -- Indica se juros esta rodando na mensal
                              ,pr_dtdpagto => to_char(pr_dtvencto, 'DD') -- Dia do primeiro vencimento do emprestimo
                              ,pr_diarefju => vr_diavtolt -- Dia da data de referência da última vez que rodou juros
                              ,pr_mesrefju => vr_mesvtolt -- Mes da data de referência da última vez que rodou juros
                              ,pr_anorefju => vr_anovtolt -- Ano da data de referência da última vez que rodou juros
                              ,pr_diafinal => pr_diarefju -- Dia data final
                              ,pr_mesfinal => pr_mesrefju -- Mes data final
                              ,pr_anofinal => pr_anorefju -- Ano data final
                              ,pr_qtdedias => vr_qtdedias); -- Quantidade de dias calculada
      
      -- Condicao para verificar se o Juros jah foi lancado
      IF vr_qtdedias <= 0 THEN
        pr_vljuremu := 0;
        RETURN;
      END IF;
      
      -- Data de Vencimento Calculada
      vr_dtvencto_calc := TO_DATE(TO_CHAR(pr_dtvencto,'DD')||'/'||TO_CHAR(pr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR');
      -- Condicao para verificar se a parcela vence hoje
      IF vr_dtvencto_calc > pr_dtmvtoan AND vr_dtvencto_calc <= pr_dtmvtolt THEN
        vr_dtvencto_calc := ADD_MONTHS(vr_dtvencto_calc,-1);
      -- Condicao para verificar se houve pagamento antes do vencimento
      ELSIF vr_dtvencto_calc > pr_dtmvtolt THEN
        vr_dtvencto_calc := ADD_MONTHS(vr_dtvencto_calc,-1);
      END IF;
      
      -- Calcula o proximo dia util da data de vencimento
      vr_dtvencto_calc := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,       --> Cooperativa conectada
                                                      pr_dtmvtolt  => vr_dtvencto_calc,  --> Data de Vencimento 
                                                      pr_tipo      => 'P');
                                                 
      -- Somar todos os Juros Remuneratorios lançados
      vr_vljuros_mensal := 0;
      OPEN cr_craplem_juros(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_dtinicio => vr_dtvencto_calc
                           ,pr_dtfim    => pr_dtmvtolt);
      FETCH cr_craplem_juros INTO vr_vljuros_mensal;
      CLOSE cr_craplem_juros;
      
      -- Somar todos os valores pagos total
      vr_vlpago_total := 0;
      OPEN cr_craplem_pago_total(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_dtinicio => vr_dtvencto_calc
                                ,pr_dtfim    => pr_dtmvtolt);
      FETCH cr_craplem_pago_total INTO vr_vlpago_total;
      CLOSE cr_craplem_pago_total;
      
      -- Somar todos os valores pagos parcial
      vr_vlpago_parcial := 0;
      OPEN cr_craplem_pago_parcial(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp);
      FETCH cr_craplem_pago_parcial INTO vr_vlpago_parcial;
      CLOSE cr_craplem_pago_parcial;
            
      -- Valor do Juros Remuneratorio
      pr_vljuremu := (NVL(pr_vlsprojt,0) +
                      NVL(vr_vljuros_mensal,0) - 
                      NVL(vr_vlpago_total,0) - 
                      NVL(vr_vlpago_parcial,0)) * 
                      NVL((POWER(1 + pr_txdiaria,vr_qtdedias)-1),0);
                      
      IF pr_vljuremu <= 0 THEN
        pr_vljuremu := 0;
      END IF;
             
    EXCEPTION
      WHEN OTHERS THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := 'Erro na procedure pc_calcula_juros_remuneratorio: ' || SQLERRM;
    END;

  END pc_calcula_juros_remuneratorio;
  
  -- Procedure a correcao de Juros do Valor Pago
  PROCEDURE pc_calcula_correcao_valor_pago(pr_cdcooper           IN crapcop.cdcooper%TYPE
                                          ,pr_dtmvtolt           IN crapdat.dtmvtolt%TYPE
                                          ,pr_dtmvtoan           IN crapdat.dtmvtoan%TYPE
                                          ,pr_dtefetiv           IN crapepr.dtmvtolt%TYPE                                          
                                          ,pr_vlpagpar           IN crappep.vlpagpar%TYPE
                                          ,pr_vlrdtaxa           IN crappep.vltaxatu%TYPE
                                          ,pr_txmensal           IN crapepr.txmensal%TYPE
                                          ,pr_dtdstjur           IN crappep.dtdstjur%TYPE
                                          ,pr_dtvencto           IN crappep.dtvencto%TYPE
                                          ,pr_vldescto_remunert OUT NUMBER
                                          ,pr_vldescto_correcao OUT NUMBER         
                                          ,pr_cdcritic          OUT crapcri.cdcritic%TYPE
                                          ,pr_dscritic          OUT crapcri.dscritic%TYPE) IS                                        
    -- Variaveis da procedure
    vr_qtdia_corridos  PLS_INTEGER;
    vr_qtdia_uteis     PLS_INTEGER;
    vr_txdiaria        craplcr.txdiaria%TYPE;
    vr_dtcomptecia     DATE;
    vr_dtcalcul        DATE;
    
    -- Variaveis para tratamento de critica
    vr_exc_erro        EXCEPTION;
    vr_cdcritic        PLS_INTEGER;
    vr_dscritic        VARCHAR2(4000);
  BEGIN
    vr_txdiaria := POWER(1 + (NVL(pr_txmensal,0) / 100),(1 / 30)) - 1;
    
    -- Data Final de Calculo
    vr_dtcalcul := pr_dtmvtolt;
    -- Data da Competencia
    vr_dtcomptecia := TO_DATE(TO_CHAR(pr_dtvencto,'DD')||'/'||TO_CHAR(pr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR');
    -- Condicao para verificar a data final de calculo
    IF vr_dtcomptecia > pr_dtmvtoan AND vr_dtcomptecia <= pr_dtmvtolt THEN
      vr_dtcalcul := vr_dtcomptecia;
    END IF;

    -- Quantidade de dias para o calculo
    EMPR0011.pc_calcula_dias360(pr_ehmensal   => FALSE
                               ,pr_dtvencto   => pr_dtvencto
                               ,pr_dtrefjur   => pr_dtdstjur
                               ,pr_data_final => vr_dtcalcul
                               ,pr_qtdedias   => vr_qtdia_corridos
                               ,pr_cdcritic   => vr_cdcritic
                               ,pr_dscritic   => vr_dscritic);
                            
    -- Condicao para verificar se houve critica
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Quantidade de dias para o calculo
    EMPR0011.pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper
                                      ,pr_flgbatch    => FALSE
                                      ,pr_dtefetiv    => pr_dtefetiv
                                      ,pr_datainicial => pr_dtdstjur
                                      ,pr_datafinal   => vr_dtcalcul
                                      ,pr_qtdiaute    => vr_qtdia_uteis
                                      ,pr_cdcritic    => vr_cdcritic
                                      ,pr_dscritic    => vr_dscritic);

    -- Condicao para verificar se houve erro
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Correção do Juros Remuneratorio            
    pr_vldescto_remunert := NVL(pr_vlpagpar,0) * (POWER(1 + vr_txdiaria,vr_qtdia_corridos) - 1);
    -- Correção do Juros de Correção
    pr_vldescto_correcao := NVL(pr_vlpagpar,0) * (POWER(1 + (pr_vlrdtaxa / 100),vr_qtdia_uteis / 252) - 1);
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Apenas retornar a variável de saida
      IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'pc_calcula_correcao_valor_pago --> Erro ao calcular a correcao do valor pago.'||sqlerrm;       
  END pc_calcula_correcao_valor_pago;

  PROCEDURE pc_calcula_juros_correcao(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                     ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento Anterior
                                     ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual
                                     ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                     ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente                                        
                                     ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                     ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de liberacao do Contrato
                                     ,pr_dtrefjur IN  crapepr.dtrefjur%TYPE     --> Data de Referencia de Juros
                                     ,pr_vlrdtaxa IN  NUMBER                    --> Valor da Taxa de Atualizacao da Parcela
                                     ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                     ,pr_insitpar IN  PLS_INTEGER DEFAULT NULL  --> Situacao da Parcela
                                     ,pr_vlsprojt IN  NUMBER                    --> Saldo Devedor Projetado
                                     ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                     ,pr_dtrefcor IN  crapepr.dtrefcor%TYPE     --> Data de Referencia do ultimo lancamento de juros de correcao
                                     ,pr_vljurcor OUT NUMBER                    --> Juros de Correcao
                                     ,pr_qtdiacal OUT craplem.qtdiacal%TYPE     --> Quantidade de dias de calculo
                                     ,pr_vltaxprd OUT craplem.vltaxprd%TYPE     --> Taxa no Periodo
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................
       Programa: pc_calcula_juros_correcao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Junho/2017                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o Juros Correcao

       Alteracoes: 
    ............................................................................. */
    
    DECLARE
      -- Buscar ultimo lancamento de Juros
      CURSOR cr_craplem_juros(pr_cdcooper IN craplem.cdcooper%TYPE
                             ,pr_nrdconta IN craplem.nrdconta%TYPE
                             ,pr_nrctremp IN craplem.nrctremp%TYPE
                             ,pr_dtinicio IN DATE
                             ,pr_dtfim    IN DATE) IS
        SELECT SUM(vllanmto) vllanmto
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND cdhistor IN (2344,2345)
           AND dtmvtolt  > pr_dtinicio
           AND dtmvtolt <= pr_dtfim;

      -- Somar todos os lancamentos de pagamento de antecipacao
      CURSOR cr_craplem_pago_total(pr_cdcooper IN craplem.cdcooper%TYPE
                                  ,pr_nrdconta IN craplem.nrdconta%TYPE
                                  ,pr_nrctremp IN craplem.nrctremp%TYPE
                                  ,pr_dtinicio IN DATE
                                  ,pr_dtfim    IN DATE) IS
        SELECT SUM(craplem.vllanmto) vllanmto
          FROM craplem
          join crappep
            on crappep.cdcooper = craplem.cdcooper
           and crappep.nrdconta = craplem.nrdconta
           and crappep.nrctremp = craplem.nrctremp
           and crappep.nrparepr = craplem.nrparepr
           and crappep.vldespar > 0
           and crappep.inliquid = 1   
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor IN (2331,2330,2335,2334)
           AND craplem.dtmvtolt >  pr_dtinicio 
           AND craplem.dtmvtolt <= pr_dtfim;     

      -- Somar todos os lancamentos de pagamento de antecipacao
      CURSOR cr_craplem_pago_parcial(pr_cdcooper IN craplem.cdcooper%TYPE
                                    ,pr_nrdconta IN craplem.nrdconta%TYPE
                                    ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT SUM(craplem.vllanmto) vllanmto
          FROM craplem
          join crappep
            on crappep.cdcooper = craplem.cdcooper
           and crappep.nrdconta = craplem.nrdconta
           and crappep.nrctremp = craplem.nrctremp
           and crappep.nrparepr = craplem.nrparepr
           and crappep.vldespar > 0
           and crappep.inliquid = 0
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.cdhistor IN (2331,2330,2335,2334);  
                      
      -- Variaveis de calculo da procedure
      vr_qtdedias       PLS_INTEGER;
      vr_taxa_periodo   NUMBER(25,8);
      vr_vlpago_total   NUMBER(25,2);
      vr_vlpago_parcial NUMBER(25,2);
      vr_vljuros_mensal craplem.vllanmto%TYPE := 0;
      vr_data_final     DATE;
      vr_data_inicial   date;
      vr_dtvencto_calc  DATE;

      -- Variaveis tratamento de erros
      vr_exc_erro       exception;
      vr_cdcritic       crapcri.cdcritic%TYPE;
      vr_dscritic       VARCHAR2(4000);
    BEGIN
      -- Logica para encontrar a data inicial do calculo do Juros de Correcao
      IF pr_dtrefcor IS NOT NULL THEN
        vr_data_inicial := pr_dtrefcor;
      ELSE
        vr_data_inicial := pr_dtlibera;
      END IF; 
      
      -- Parcela em Dia
      IF pr_insitpar = 1 THEN
        vr_data_final := pr_dtvencto;
      -- Parcela a Vencer  
      ELSIF pr_insitpar = 3 THEN
        vr_data_final := pr_dtmvtolt;
      -- Mensal  
      ELSIF pr_ehmensal THEN
        vr_data_final := last_day(pr_dtmvtolt);
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

      -- Data de Vencimento Calculada
      vr_dtvencto_calc := TO_DATE(TO_CHAR(pr_dtvencto,'DD')||'/'||TO_CHAR(pr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR');
      -- Condicao para verificar se estah em dia
      IF vr_dtvencto_calc > pr_dtmvtoan AND vr_dtvencto_calc <= pr_dtmvtolt THEN
        vr_dtvencto_calc := ADD_MONTHS(vr_dtvencto_calc,-1);
      -- Condicao para verificar se houve pagamento antes do vencimento
      ELSIF vr_dtvencto_calc > pr_dtmvtolt THEN
        vr_dtvencto_calc := ADD_MONTHS(vr_dtvencto_calc,-1);
      END IF;      
      -- Calcula o proximo dia util da data de vencimento
      vr_dtvencto_calc := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,       --> Cooperativa conectada
                                                      pr_dtmvtolt  => vr_dtvencto_calc,  --> Data de Vencimento 
                                                      pr_tipo      => 'P');
                                                      
      vr_vljuros_mensal := 0;
      -- Somar o Juros Remuneratorio
      OPEN cr_craplem_juros(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_dtinicio => vr_dtvencto_calc
                           ,pr_dtfim    => pr_dtmvtolt);
      FETCH cr_craplem_juros INTO vr_vljuros_mensal;
      CLOSE cr_craplem_juros;
      
      -- Somar todos os pagamento dentro do periodo
      vr_vlpago_total := 0;
      OPEN cr_craplem_pago_total(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_dtinicio => vr_dtvencto_calc
                                ,pr_dtfim    => pr_dtmvtolt);
      FETCH cr_craplem_pago_total INTO vr_vlpago_total;
      CLOSE cr_craplem_pago_total;
      
      -- Somar todos os valores pagos parcial
      vr_vlpago_parcial := 0;
      OPEN cr_craplem_pago_parcial(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp);
      FETCH cr_craplem_pago_parcial INTO vr_vlpago_parcial;
      CLOSE cr_craplem_pago_parcial;   
      
      -- Valor do Juros de Correcao
      pr_vljurcor := (NVL(pr_vlsprojt,0) +
                      NVL(vr_vljuros_mensal,0) - 
                      NVL(vr_vlpago_total,0) - 
                      NVL(vr_vlpago_parcial,0)) * 
                      vr_taxa_periodo;
                      
      -- Quantidade de dias utilizado para o calculo
      pr_qtdiacal := vr_qtdedias;
      -- Taxa do periodo calculado
      pr_vltaxprd := vr_taxa_periodo;
                   
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
        pr_dscritic := 'Erro na procedure pc_calcula_juros_correcao: ' || SQLERRM;
    END;

  END pc_calcula_juros_correcao;

  PROCEDURE pc_busca_pagto_parc_pos(pr_cdcooper     IN crapepr.cdcooper%TYPE      --> Codigo da Cooperativa
                                   ,pr_cdprogra     IN crapprg.cdprogra%TYPE      --> Codigo do Programa
                                   ,pr_flgbatch     IN BOOLEAN DEFAULT FALSE      --> Indica se o processo noturno estah rodando
                                   ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE      --> Data de calculo das parcelas
                                   ,pr_dtmvtoan     IN crapdat.dtmvtoan%TYPE      --> Data do movimento anterior
                                   ,pr_nrdconta     IN crapepr.nrdconta%TYPE      --> Numero da Conta Corrente
                                   ,pr_nrctremp     IN crapepr.nrctremp%TYPE      --> Numero do Contrato
                                   ,pr_dtefetiv     IN crapepr.dtmvtolt%TYPE      --> Data de Efetivacao do Contrato de Emprestimo
                                   ,pr_cdlcremp     IN crapepr.cdlcremp%TYPE      --> Codigo da linha de credito
                                   ,pr_vlemprst     IN crapepr.vlemprst%TYPE      --> Valor do Emprestimo
                                   ,pr_txmensal     IN crawepr.txmensal%TYPE      --> Taxa Mensal do Contrato de Emprestimo
                                   ,pr_dtdpagto     IN crawepr.dtdpagto%TYPE      --> Data de Pagamento do Primeiro Vencimento
                                   ,pr_vlsprojt     IN crapepr.vlsprojt%TYPE
                                   ,pr_qttolatr     IN crapepr.qttolatr%TYPE      --> Tolerancia para cobranca de multa e mora parcelas atraso
                                   ,pr_tab_parcelas OUT EMPR0011.typ_tab_parcelas --> Temp-Table contendo todas as parcelas calculadas
																	 ,pr_tab_calculado OUT empr0011.typ_tab_calculado --> Tabela com totais calculados
                                   ,pr_cdcritic     OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                   ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_busca_pagto_parc_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Abril/2017                         Ultima atualizacao: 09/01/2019

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o saldo devedor do contrato

       Alteracoes: 10/05/2018 - P410 - Ajustes IOF (Marcos-Envolti)
			             09/01/2019 - PRJ298.2.2 - Inclusao da Transferencia para prejuizo para o Pos - Nagasava (Supero)
    ............................................................................. */
    DECLARE
      -- Cursor da Linha de Crédito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT cdlcremp
              ,flgcobmu
              ,perjurmo
          FROM craplcr
         WHERE cdcooper = DECODE(pr_cdcooper,0,cdcooper,pr_cdcooper)
           AND cdlcremp = DECODE(pr_cdlcremp,0,cdlcremp,pr_cdlcremp);
      rw_craplcr cr_craplcr%ROWTYPE;      

			-- Busca dos dados de complemento do emprestimo
      CURSOR cr_crawepr IS
        SELECT epr.dtlibera
				      ,epr.idfiniof
          FROM crawepr epr
         WHERE epr.cdcooper = pr_cdcooper
					 AND epr.nrdconta = pr_nrdconta
					 AND epr.nrctremp = pr_nrctremp;
      --
			rw_crawepr cr_crawepr%ROWTYPE;
			
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
               crappep.vlpagpar,
               crappep.vltaxatu,
               crappep.dtdstjur,
               crappep.vldstcor,
               crappep.vldstrem,
							 crappep.inliquid
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           and crappep.inliquid = 0;
        
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
      --
      rw_craplem cr_craplem%ROWTYPE;
			
      -- Variveis Procedure
      vr_dstextab          craptab.dstextab%TYPE;
      vr_indice            PLS_INTEGER;
      vr_percmult          NUMBER(25,2);
      vr_perjurmo          craplcr.perjurmo%TYPE;
      vr_indx              VARCHAR2(20);
      vr_tab_price         typ_tab_price;
      vr_vldescto_remunert NUMBER(25,2);
      vr_vldescto_correcao NUMBER(25,2);
      vr_vlpagto_corrigido crappep.vlpagpar%TYPE;
   
      -- Variaveis tratamento de erros
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      vr_exc_erro   EXCEPTION;

			-- Indice para o Array de historicos
      vr_vlsdeved   NUMBER := 0; --> Saldo devedor
      vr_vlpreapg   NUMBER := 0; --> Qtde parcela a pagar
      vr_vlsderel   NUMBER := 0; --> Saldo para relatórios
      vr_vlsdvctr   NUMBER := 0;

      -- Obter o % de multa da CECRED - TAB090
      PROCEDURE pc_busca_tab(pr_dstextab OUT craptab.dstextab%TYPE) IS
      BEGIN
        pr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3 -- Fixo 3 - Cecred
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'PAREMPCTL'
                                                 ,pr_tpregist => 01);
      END pc_busca_tab;

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
			--
      pr_tab_parcelas.DELETE;
      vr_tab_price.DELETE;

      -- Se estiver rodando no processo
      IF pr_flgbatch THEN

        -- Se Linhas de Credito NAO foram carregadas
        IF vr_tab_craplcr.COUNT = 0 THEN
          -- Obter o % de multa da CECRED - TAB090
          pc_busca_tab(pr_dstextab => vr_dstextab);
          IF vr_dstextab IS NULL THEN
            vr_cdcritic := 55;
            RAISE vr_exc_erro;
          END IF;

          -- Listagem de Linha de Credito
          FOR rw_craplcr IN cr_craplcr(pr_cdcooper => 0
                                      ,pr_cdlcremp => 0) LOOP
            -- Chave por cooperativa e linha de credito
            vr_indx := LPAD(pr_cdcooper,10,'0') || LPAD(rw_craplcr.cdlcremp,10,'0');
            vr_tab_craplcr(vr_indx).perjurmo := rw_craplcr.perjurmo;
            -- Se for cobrar multa
            IF rw_craplcr.flgcobmu = 1 THEN
              vr_tab_craplcr(vr_indx).percmult := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,1,6));
            ELSE
              vr_tab_craplcr(vr_indx).percmult := 0;
            END IF;
          END LOOP;
        END IF;
      	  
        vr_indx := LPAD(pr_cdcooper,10,'0') || LPAD(pr_cdlcremp,10,'0');
        vr_percmult := vr_tab_craplcr(vr_indx).percmult;
        vr_perjurmo := vr_tab_craplcr(vr_indx).perjurmo;

      ELSE
        -- Buscar os dados da linha de crédito
        OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                         ,pr_cdlcremp => pr_cdlcremp);
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
          pc_busca_tab(pr_dstextab => vr_dstextab);
          IF vr_dstextab IS NULL THEN
            vr_cdcritic := 55;
            RAISE vr_exc_erro;
          END IF;
          -- Utilizar como % de multa, as 6 primeiras posições encontradas
          vr_percmult := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,1,6));
        ELSE
          vr_percmult := 0;
        END IF;
        
        vr_perjurmo := rw_craplcr.perjurmo;

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
        pr_tab_parcelas(vr_indice).dtultpag := rw_crappep.dtultpag;
        pr_tab_parcelas(vr_indice).vlsdvpar := rw_crappep.vlsdvpar;
        pr_tab_parcelas(vr_indice).vlpagpar := rw_crappep.vlpagpar;
        pr_tab_parcelas(vr_indice).vlrdtaxa := rw_crappep.vltaxatu;
        pr_tab_parcelas(vr_indice).dtdstjur := rw_crappep.dtdstjur;
        pr_tab_parcelas(vr_indice).vldstcor := rw_crappep.vldstcor;
        pr_tab_parcelas(vr_indice).vldstrem := rw_crappep.vldstrem;
        pr_tab_parcelas(vr_indice).vlatupar := rw_crappep.vlsdvpar;
				pr_tab_parcelas(vr_indice).inliquid := rw_crappep.inliquid;
        vr_vldescto_remunert := 0;
        vr_vldescto_correcao := 0;
        vr_vlpagto_corrigido := 0;

        --------------------------------------------------------------------------------------------
        -- INICIO: Efetuar a correcao do valor pago da parcela
        --------------------------------------------------------------------------------------------
        -- Condicao para verificar se houve valor pago
        IF pr_tab_parcelas(vr_indice).vlpagpar > 0            AND 
           -- Somente sera corrigido o valor para a parcela principal
           pr_tab_parcelas(vr_indice).dtvencto >= pr_dtdpagto AND
           -- Somente sera corrigido para as parcelas que vence hoje OU parcelas que irao vencer
           ((rw_crappep.dtvencto > pr_dtmvtoan AND rw_crappep.dtvencto <= pr_dtmvtolt) OR (rw_crappep.dtvencto > pr_dtmvtolt)) THEN
                      
           -- Procedure para calcular a correcao do Juros do Valor Pago
           pc_calcula_correcao_valor_pago(pr_cdcooper           => pr_cdcooper
                                         ,pr_dtmvtolt           => pr_dtmvtolt
                                         ,pr_dtmvtoan           => pr_dtmvtoan
                                         ,pr_dtefetiv           => pr_dtefetiv
                                         ,pr_vlpagpar           => NVL(pr_tab_parcelas(vr_indice).vlpagpar,0) +
                                                                   NVL(pr_tab_parcelas(vr_indice).vldstcor,0) +
                                                                   NVL(pr_tab_parcelas(vr_indice).vldstrem,0)
                                         ,pr_vlrdtaxa           => pr_tab_parcelas(vr_indice).vlrdtaxa
                                         ,pr_txmensal           => pr_txmensal
                                         ,pr_dtdstjur           => pr_tab_parcelas(vr_indice).dtdstjur
                                         ,pr_dtvencto           => pr_tab_parcelas(vr_indice).dtvencto                                          
                                         ,pr_vldescto_remunert  => vr_vldescto_remunert
                                         ,pr_vldescto_correcao  => vr_vldescto_correcao
                                         ,pr_cdcritic           => vr_cdcritic
                                         ,pr_dscritic           => vr_dscritic);
           -- Condicao para verificar se houve critica
           IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_erro;
           END IF;
        END IF;
        
        ------------------------------------------------------------------------------------------
        --  Correcao do Valor Pago da Parcela
        ------------------------------------------------------------------------------------------
        -- Desconto de Juros de Correcao
        pr_tab_parcelas(vr_indice).vldstcor_atu := NVL(pr_tab_parcelas(vr_indice).vldstcor,0) + 
                                                   NVL(vr_vldescto_correcao,0);
        -- Desconto do Juros Remuneratorio
        pr_tab_parcelas(vr_indice).vldstrem_atu := NVL(pr_tab_parcelas(vr_indice).vldstrem,0) + 
                                                   NVL(vr_vldescto_remunert,0);
        -- Valor Pago da Parcela
        pr_tab_parcelas(vr_indice).vlpagpar := NVL(pr_tab_parcelas(vr_indice).vlpagpar,0) + 
                                               NVL(pr_tab_parcelas(vr_indice).vldstcor_atu,0) + 
                                               NVL(pr_tab_parcelas(vr_indice).vldstrem_atu,0);
        -- Somente para parcelas a Vencer                               
        /*IF rw_crappep.dtvencto > pr_dtmvtolt THEN        
          
          -- Atualiza o Saldo Devedor da Parcela
          pr_tab_parcelas(vr_indice).vlatupar := NVL(pr_tab_parcelas(vr_indice).vlatupar,0) - 
                                                 NVL(vr_vldescto_correcao,0) - 
                                                 NVL(vr_vldescto_remunert,0);
        END IF; */
        ------------------------------------------------------------------------------------------
        --  Calculo das parcelas
        ------------------------------------------------------------------------------------------        
        -- Se ainda não foi liberado
        IF pr_dtmvtolt <= rw_crawepr.dtlibera THEN
					-- Guardar quantidades calculadas
          vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;
					--
				END IF;
        -- Parcela em dia
        IF rw_crappep.dtvencto > pr_dtmvtoan AND rw_crappep.dtvencto <= pr_dtmvtolt THEN
					--
          pr_tab_parcelas(vr_indice).insitpar := 1; -- Em Dia

					-- Guardar quantidades calculadas
					vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;

					-- A regularizar
					vr_vlpreapg := vr_vlpreapg + rw_crappep.vlsdvpar;

        -- Parcela em Atraso
        ELSIF rw_crappep.dtvencto < pr_dtmvtolt THEN
          -- Procedure para calcular o valor do atraso
          pc_calcula_atraso_pos_fixado (pr_cdcooper => pr_cdcooper
                                       ,pr_cdprogra => pr_cdprogra
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_cdlcremp => pr_cdlcremp
                                       ,pr_dtcalcul => pr_dtmvtolt
                                       ,pr_vlemprst => pr_vlemprst
                                       ,pr_nrparepr => rw_crappep.nrparepr
                                       ,pr_vlparepr => rw_crappep.vlparepr
                                       ,pr_dtvencto => rw_crappep.dtvencto
                                       ,pr_dtultpag => rw_crappep.dtultpag
                                       ,pr_vlsdvpar => pr_tab_parcelas(vr_indice).vlatupar
                                       ,pr_perjurmo => vr_perjurmo
                                       ,pr_vlpagmta => rw_crappep.vlpagmta
                                       ,pr_percmult => vr_percmult
                                       ,pr_txmensal => pr_txmensal
                                       ,pr_qttolatr => pr_qttolatr
                                       ,pr_vlmrapar => pr_tab_parcelas(vr_indice).vlmrapar
                                       ,pr_vlmtapar => pr_tab_parcelas(vr_indice).vlmtapar
                                       ,pr_vliofcpl => pr_tab_parcelas(vr_indice).vliofcpl
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
          
					-- Acumular o valor a regularizar
					vr_vlpreapg := vr_vlpreapg + pr_tab_parcelas(vr_indice).vlatupar;
					-- Guardar quantidades calculadas
					vr_vlsdvctr := vr_vlsdvctr + pr_tab_parcelas(vr_indice).vlatupar;
          
        -- Parcela à Vencer
        ELSIF rw_crappep.dtvencto > pr_dtmvtolt THEN
          -- Calcula o desconto da parcela
          EMPR0011.pc_calcula_desconto_pos(pr_dtcalcul  => pr_dtmvtolt
                                          ,pr_flgbatch  => pr_flgbatch
                                          ,pr_cdcooper  => pr_cdcooper
                                          ,pr_dtefetiv  => pr_dtefetiv
                                          ,pr_txmensal  => pr_txmensal
                                          ,pr_dtdpagto  => pr_dtdpagto
                                          ,pr_vlsprojt  => pr_vlsprojt
                                          ,pr_nrparepr  => rw_crappep.nrparepr
                                          ,pr_dtvencto  => rw_crappep.dtvencto
                                          ,pr_vlsdvpar  => pr_tab_parcelas(vr_indice).vlatupar
                                          ,pr_vltaxatu  => rw_crappep.vltaxatu
                                          ,pr_tab_price => vr_tab_price
                                          ,pr_vlatupar  => pr_tab_parcelas(vr_indice).vlatupar
                                          ,pr_vldescto  => pr_tab_parcelas(vr_indice).vldescto
                                          ,pr_cdcritic  => vr_cdcritic
                                          ,pr_dscritic  => vr_dscritic);
          
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- A Vencer
          pr_tab_parcelas(vr_indice).insitpar := 3;          
          
          -- Somente sera carregado os valores de vencimento a vencer, dentro do mês (LAUTOM)
          IF (to_char(rw_crappep.dtvencto,'RRRRMM') = to_char(pr_dtmvtolt,'RRRRMM')) THEN
            pr_tab_parcelas(vr_indice).vlpraven := NVL(rw_crappep.vlsdvpar,0);
          END IF;         
          
					-- Guardar quantidades calculadas
          vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;        
          
        END IF;
				
        -- Valor atual da parcela mais multa e juros de mora
        pr_tab_parcelas(vr_indice).vlatrpag := NVL(pr_tab_parcelas(vr_indice).vlatupar,0)
                                             + NVL(pr_tab_parcelas(vr_indice).vlmtapar,0)
                                             + NVL(pr_tab_parcelas(vr_indice).vlmrapar,0)
                                             + NVL(pr_tab_parcelas(vr_indice).vliofcpl,0);
        -- Somente calcular se o empréstimo estiver liberado
				IF NOT pr_dtmvtolt <= rw_crawepr.dtlibera THEN
					-- Saldo para relatorios
					vr_vlsderel := vr_vlsderel + pr_tab_parcelas(vr_indice).vlatupar;
					-- Saldo devedor total do emprestimo
					vr_vlsdeved := vr_vlsdeved + pr_tab_parcelas(vr_indice).vlatrpag;
					--
				END IF;
				--
      END LOOP;

			-- Se o empréstimo ainda não estiver liberado e não esteja liquidado
			IF pr_dtmvtolt <= rw_crawepr.dtlibera AND rw_crapepr.inliquid <> 1 THEN
				-- Continuar com os valores da tabela
				pr_tab_calculado(1).vlsdeved := rw_crapepr.vlemprst;
				pr_tab_calculado(1).vlsderel := rw_crapepr.vlemprst;
				--
			ELSE
				-- Utilizar informações do cálculo
				pr_tab_calculado(1).vlsdeved := vr_vlsdeved;
				pr_tab_calculado(1).vlsderel := vr_vlsderel;
        --
			END IF;
      --
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
                                        ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Codigo do Programa
                                        ,pr_dtmvtolt  IN VARCHAR2                  --> Data de calculo das parcelas
                                        ,pr_dtmvtoan  IN VARCHAR2                  --> Data de movimento anterior
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE     --> Numero do Contrato
                                        ,pr_vlsdeved OUT NUMBER                    --> Valor atualizado
                                        ,pr_vlprvenc OUT NUMBER                    --> Parcela Vencida
                                        ,pr_vlpraven OUT NUMBER                    --> Parcela EM DIA + Parcela A VENCER
                                        ,pr_vlmtapar OUT NUMBER                    --> Valor da multa por atraso
                                        ,pr_vlmrapar OUT NUMBER                    --> Valor de juros pelo atraso
                                        ,pr_vliofcpl OUT NUMBER                    --> Valor de juros pelo atraso
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
      -- Cursor de emprestimo
      CURSOR cr_crapepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT crapepr.dtmvtolt
              ,crawepr.txmensal
              ,crawepr.cddindex
              ,crawepr.cdlcremp
              ,crawepr.dtdpagto
              ,crapepr.vlsprojt
              ,crapepr.vlemprst
              ,crapepr.qttolatr
          FROM crapepr
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      -- Variaveis gerais
      vr_indice       PLS_INTEGER;
      vr_dtmvtolt     crapdat.dtmvtolt%TYPE;
      vr_dtmvtoan     crapdat.dtmvtoan%TYPE;
      vr_tab_parcelas typ_tab_parcelas;
			vr_tab_calculado typ_tab_calculado;
      vr_vlpreapg     NUMBER := 0;
      vr_vlprvenc     NUMBER := 0;
      vr_vlpraven     NUMBER := 0;
      vr_vlmtapar     NUMBER := 0;
      vr_vlmrapar     NUMBER := 0;
  	  vr_vliofcpl     NUMBER := 0;
      vr_blnachou     BOOLEAN;

      -- Variaveis tratamento de erros
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      vr_exc_erro   EXCEPTION;

    BEGIN
      -- Converte para data
      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/RRRR');
      vr_dtmvtoan := TO_DATE(pr_dtmvtoan,'DD/MM/RRRR');
      
      -- Buscar os dados de emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
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
  	
      -- Busca as parcelas para pagamento
      pc_busca_pagto_parc_pos(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => pr_cdprogra
                             ,pr_dtmvtolt => vr_dtmvtolt
                             ,pr_dtmvtoan => vr_dtmvtoan
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_dtefetiv => rw_crapepr.dtmvtolt
                             ,pr_cdlcremp => rw_crapepr.cdlcremp
                             ,pr_vlemprst => rw_crapepr.vlemprst
                             ,pr_txmensal => rw_crapepr.txmensal
                             ,pr_dtdpagto => rw_crapepr.dtdpagto
                             ,pr_vlsprojt => rw_crapepr.vlsprojt
                             ,pr_qttolatr => rw_crapepr.qttolatr
                             ,pr_tab_parcelas => vr_tab_parcelas
														 ,pr_tab_calculado => vr_tab_calculado
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
        vr_vliofcpl := vr_vliofcpl + NVL(vr_tab_parcelas(vr_indice).vliofcpl,0);

        CASE vr_tab_parcelas(vr_indice).insitpar
          -- Em Dia
          WHEN 1 THEN vr_vlpraven := vr_vlpraven + NVL(vr_tab_parcelas(vr_indice).vlatupar,0);
          -- Em Atraso
          WHEN 2 THEN vr_vlprvenc := vr_vlprvenc + NVL(vr_tab_parcelas(vr_indice).vlatupar,0);
          -- A Vencer
          WHEN 3 THEN vr_vlpraven := vr_vlpraven + NVL(vr_tab_parcelas(vr_indice).vlpraven,0);
        END CASE;

        vr_indice   := vr_tab_parcelas.NEXT(vr_indice);
      END LOOP;

      -- Retorna valores
      pr_vlsdeved := vr_vlpreapg;
      pr_vlprvenc := vr_vlprvenc;
      pr_vlpraven := vr_vlpraven;
      pr_vlmtapar := vr_vlmtapar;
      pr_vlmrapar := vr_vlmrapar;
  	  pr_vliofcpl := vr_vliofcpl;

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
                                       ,pr_dtmvtolt     IN VARCHAR2                   --> Data de calculo das parcelas
                                       ,pr_dtmvtoan     IN VARCHAR2 DEFAULT NULL      --> Data de movimento anterior
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
      -- Cursor de emprestimo
      CURSOR cr_crapepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT crapepr.dtmvtolt
              ,crawepr.txmensal
              ,crawepr.cddindex
              ,crawepr.dtdpagto
              ,crapepr.vlsprojt
              ,crapepr.vlemprst
              ,crapepr.cdlcremp
              ,crapepr.qttolatr
          FROM crapepr
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      -- Variaveis gerais
      vr_indice       PLS_INTEGER;
      vr_contador     INTEGER := 0;
      vr_dtmvtolt     crapdat.dtmvtolt%TYPE;
      vr_dtmvtoan     crapdat.dtmvtoan%TYPE;
      vr_blnachou     BOOLEAN;
      vr_tab_parcelas typ_tab_parcelas;
			vr_tab_calculado typ_tab_calculado;

      -- Variaveis tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      vr_exc_erro     EXCEPTION;
      
      -- Variaveis de log
      vr_cdcooper     INTEGER;
      vr_cdoperad     VARCHAR2(100);
      vr_nmdatela     VARCHAR2(100);
      vr_nmeacao      VARCHAR2(100);
      vr_cdagenci     VARCHAR2(100);
      vr_nrdcaixa     VARCHAR2(100);
      vr_idorigem     VARCHAR2(100);

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_busca_pagto_parc_pos_web'
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
                              
      -- Converte para data
      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/RRRR');
      
      IF pr_dtmvtoan IS NOT NULL THEN
      vr_dtmvtoan := TO_DATE(pr_dtmvtoan,'DD/MM/RRRR');
      ELSE
        vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_dtmvtolt - 1
                                                  ,pr_tipo => 'A');
      END IF;

     	-- Buscar os dados de emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
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
  	
      -- Busca as parcelas para pagamento
      pc_busca_pagto_parc_pos(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_nmdatela
                             ,pr_dtmvtolt => vr_dtmvtolt
                             ,pr_dtmvtoan => vr_dtmvtoan
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_dtefetiv => rw_crapepr.dtmvtolt
                             ,pr_cdlcremp => rw_crapepr.cdlcremp
                             ,pr_vlemprst => rw_crapepr.vlemprst
                             ,pr_txmensal => rw_crapepr.txmensal
                             ,pr_dtdpagto => rw_crapepr.dtdpagto
                             ,pr_vlsprojt => rw_crapepr.vlsprojt
                             ,pr_qttolatr => rw_crapepr.qttolatr
                             ,pr_tab_parcelas => vr_tab_parcelas
														 ,pr_tab_calculado => vr_tab_calculado
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
                              ,pr_tag_nova => 'vliofcpl'
                              ,pr_tag_cont => TO_CHAR(NVL(vr_tab_parcelas(vr_indice).vliofcpl,0),'FM999G999G999G990D00')
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
      IF TO_CHAR(pr_dtdpagto, 'RRRRMM') <= TO_CHAR(pr_dtcarenc, 'RRRRMM') THEN
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

  PROCEDURE pc_grava_parcel_pos_fixado(pr_cdcooper         IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_nrdconta         IN crapass.nrdconta%TYPE     --> Numero da Conta
                                      ,pr_dtcalcul         IN crapdat.dtmvtolt%TYPE     --> Data de Calculo
                                      ,pr_nrctremp         IN crapepr.nrctremp%TYPE     --> Numero do contrato
                                      ,pr_cdlcremp         IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_vlemprst         IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                      ,pr_qtparepr         IN crapepr.qtpreemp%TYPE     --> Quantidade de parcelas
                                      ,pr_dtcarenc         IN crawepr.dtcarenc%TYPE     --> Data da Carência
                                      ,pr_dtdpagto         IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_qtdias_carencia  IN tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias
                                      ,pr_vlpreemp        OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                      ,pr_txdiaria        OUT crawepr.txdiaria%TYPE     --> Taxa diaria
                                      ,pr_txmensal        OUT crawepr.txmensal%TYPE     --> Taxa mensal
                                      ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_grava_parcel_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Abril/2017                         Ultima atualizacao: 25/06/2019

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para gravar as parcelas do Pos-Fixado.

       Alteracoes: 27/12/2018 - PJ298.2 Criado campo vlprecar e alterando gravacao do campo vlpreemp (Rafael Faria - Supero)
			             08/01/2018 - PRJ298.2.2 - Ajustar e validar rotinas respeitando aplicação da varição do indexador - Nagasava (Supero)
                   25/06/2019 - PRJ298.3 - Incluir trava para o produto Pós-Fixado no botão atualizar data como ocorre atualmente para o Pré-Fixado (Nagasava - Supero)
    ............................................................................. */

    DECLARE
      -- Variaveis locais
      vr_ind_parcelas BINARY_INTEGER;
      vr_tab_parcelas typ_tab_parcelas;
      vr_txdiaria     craplcr.txdiaria%TYPE;
      vr_vlpreemp     crapepr.vlpreemp%TYPE := 0;
      vr_vlprecar     crawepr.vlprecar%TYPE := 0;
      vr_dtdpagto     crapepr.dtdpagto%TYPE;
      vr_vlemprst     crapepr.vlemprst%TYPE;
      vr_dsbemgar     VARCHAR2(32000);
      vr_retorno01    craplem.vllanmto%TYPE;
      vr_retorno02    craplcm.vllanmto%TYPE;
      vr_retorno03    craplcm.vllanmto%TYPE;
      vr_retorno04    PLS_INTEGER;
      vr_retorno05    craplcm.vllanmto%TYPE;
      vr_blnachou     BOOLEAN;

      vr_vltarifa          number;
      vr_vltarifaN         number;
      vr_vltarifaES        number;
      vr_vltarifaGT        number;
      vr_cdhistor          craphis.cdhistor%type;
      vr_cdfvlcop          crapfco.cdfvlcop%type;
      vr_cdhisgar          craphis.cdhistor%type;
      vr_cdfvlgar          crapfco.cdfvlcop%type;
      
      -- Variaveis tratamento de erros
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      vr_exc_erro     EXCEPTION;

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
           
      -- Busca os dados da linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT txmensal
              ,cdusolcr
              ,tpctrato
							,vlperidx
          FROM craplcr 
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      
      -- Cursor de Emprestimo
      CURSOR cr_crawepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT dtlibera
              ,idfiniof
              ,cdfinemp
          FROM crawepr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;           
      
      -- Busca o associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.inpessoa
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
	        
    BEGIN
			-- Pos-Fixado 2.3
			pc_valida_dados_pos_fixado(pr_cdcooper => pr_cdcooper -- IN
																,pr_dtmvtolt => pr_dtcalcul -- IN
																,pr_cdlcremp => pr_cdlcremp -- IN
																,pr_vlemprst => pr_vlemprst -- IN
																,pr_qtparepr => pr_qtparepr -- IN
																,pr_dtlibera => rw_crawepr.dtlibera -- IN
																,pr_dtdpagto => pr_dtdpagto -- IN
																,pr_dtcarenc => pr_dtcarenc -- IN
																,pr_flgpagto => 0 -- IN
																,pr_cdcritic => vr_cdcritic -- OUT
																,pr_dscritic => vr_dscritic -- OUT
																);
			-- Se retornou erro
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
			--
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
      
      /* ----------------------------------------------------------------------------------------
                        ANDRINO -> PROVISORIO, SERA AJUSTADO NA PROXIMA LIBERACAO         
         ----------------------------------------------------------------------------------------*/
      vr_dsbemgar := '';
      -- Percorrer todos os bens da Proposta de Emprestimo
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp) LOOP
        vr_dsbemgar := vr_dsbemgar || '|' || rw_crapbpr.dscatbem;
      END LOOP;
      
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
      
      -- Buscar a taxa de juros
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => pr_cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      CLOSE cr_craplcr; 
      
      -- Calcular IOF
      tiof0001.pc_calcula_iof_epr(pr_cdcooper  		    => pr_cdcooper
                               ,pr_nrdconta  		    => pr_nrdconta
                               ,pr_nrctremp  		    => pr_nrctremp
                               ,pr_dtmvtolt  		    => pr_dtcalcul
                               ,pr_inpessoa  		    => rw_crapass.inpessoa
                               ,pr_cdlcremp  		    => pr_cdlcremp
                                 ,pr_cdfinemp         => rw_crawepr.cdfinemp
                               ,pr_qtpreemp  		    => pr_qtparepr
                               ,pr_vlpreemp  		   	=> pr_vlpreemp
                               ,pr_vlemprst  		    => pr_vlemprst
                               ,pr_dtdpagto  		    => pr_dtdpagto
                               ,pr_dtlibera  		    => rw_crawepr.dtlibera
                               ,pr_tpemprst  		    => 2
                               ,pr_dtcarenc       	=> pr_dtcarenc
                               ,pr_qtdias_carencia	=> pr_qtdias_carencia
                               ,pr_dscatbem       	=> vr_dsbemgar
                               ,pr_idfiniof       	=> rw_crawepr.idfiniof
                                 ,pr_dsctrliq         => NULL
                                 ,pr_idgravar         => 'N'
                                 ,pr_vlpreclc         => vr_retorno05
                               ,pr_valoriof       	=> vr_retorno01
                               ,pr_vliofpri       	=> vr_retorno02
                               ,pr_vliofadi       	=> vr_retorno03
                               ,pr_flgimune       	=> vr_retorno04
                               ,pr_dscritic 		    => vr_dscritic);      
                         
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Caso financie IOF  e haja valor de IOF
      if nvl(rw_crawepr.idfiniof,0) = 1 then
        -- Calcular Tarifa
        TARI0001.pc_calcula_tarifa(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_cdlcremp => pr_cdlcremp
                                  ,pr_vlemprst => pr_vlemprst
                                  ,pr_cdusolcr => rw_craplcr.cdusolcr
                                  ,pr_tpctrato => rw_craplcr.tpctrato
                                  ,pr_dsbemgar => vr_dsbemgar
                                  ,pr_cdprogra => 'ATENDA'
                                  ,pr_flgemail => 'N'
                                  ,pr_vlrtarif => vr_vltarifa
                                  ,pr_vltrfesp => vr_vltarifaES
                                  ,pr_vltrfgar => vr_vltarifaGT
                                  ,pr_cdhistor => vr_cdhistor
                                  ,pr_cdfvlcop => vr_cdfvlcop
                                  ,pr_cdhisgar => vr_cdhisgar
                                  ,pr_cdfvlgar => vr_cdfvlgar
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
        if nvl(vr_cdcritic,0) > 0 or vr_dscritic is not null then
          raise vr_exc_erro;
        end if;  
        -- Acumular tarifa
        vr_vltarifaN := vr_vltarifa + vr_vltarifaES + vr_vltarifaGT;    
        -- Acumular emprestimo + TArifa
        vr_vlemprst := round(pr_vlemprst + nvl(vr_vltarifaN,0),2);
        vr_vlemprst := ROUND(vr_vlemprst / ((vr_vlemprst - nvl(vr_retorno02,0) - nvl(vr_retorno03,0)) / vr_vlemprst),2)+0.01;
      ELSE
        -- Valor do empréstimo normal
        vr_vlemprst := pr_vlemprst;
      END IF;

      -- Chama o calculo das parcelas
      pc_calcula_parcelas_pos_fixado(pr_cdcooper        => pr_cdcooper
                                    ,pr_dtcalcul        => pr_dtcalcul
                                    ,pr_cdlcremp        => pr_cdlcremp
                                    ,pr_dtcarenc        => pr_dtcarenc
                                    ,pr_qtdias_carencia => pr_qtdias_carencia
                                    ,pr_dtdpagto        => pr_dtdpagto
                                    ,pr_qtpreemp        => pr_qtparepr
                                    ,pr_vlemprst        => vr_vlemprst
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

        -- Guarda a prestacao e data apenas uma vez
        IF vr_vlpreemp = 0 THEN
          --vr_vlpreemp := vr_tab_parcelas(vr_ind_parcelas).vlparepr;
          vr_dtdpagto := vr_tab_parcelas(vr_ind_parcelas).dtvencto;
        END IF;

        IF vr_tab_parcelas(vr_ind_parcelas).flcarenc = 1 and vr_vlprecar = 0 THEN
          vr_vlprecar := vr_tab_parcelas(vr_ind_parcelas).vlparepr;
        END IF;
        
        IF vr_tab_parcelas(vr_ind_parcelas).flcarenc = 0 and vr_vlpreemp = 0 THEN
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
        vr_ind_parcelas := vr_tab_parcelas.NEXT(vr_ind_parcelas);
      END LOOP;
      
      -- Taxa de juros remunerados mensal
      vr_txdiaria := POWER(1 + (NVL(rw_craplcr.txmensal,0) / 100),(1 / 30)) - 1;

      BEGIN
        UPDATE crawepr
           SET vlpreemp = vr_vlpreemp
              ,vlprecar = vr_vlprecar
              ,txdiaria = vr_txdiaria
              ,txmensal = rw_craplcr.txmensal
							,vlperidx = rw_craplcr.vlperidx
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      EXCEPTION
	      WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar dados da crawepr: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      BEGIN
        UPDATE crapepr
           SET dtdpagto = vr_dtdpagto
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      EXCEPTION
	      WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar dados da crapepr: ' || SQLERRM;
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

  PROCEDURE pc_busca_vl_prest_pos_prog(pr_cdcooper         IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtcalcul         IN crapdat.dtmvtoan%TYPE     --> Data do movimento anterior
                                      ,pr_cdlcremp         IN crapepr.cdlcremp%TYPE     --> Codigo da linha de credito
                                      ,pr_qtpreemp         IN crapepr.qtpreemp%TYPE     --> Quantidade de prestacoes
                                      ,pr_dtcarenc         IN crawepr.dtcarenc%TYPE     --> Data de Pagamento da Primeira Carência
                                      ,pr_dtdpagto         IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                      ,pr_vlsdeved         IN crapepr.vlsdeved%TYPE     --> Valor do saldo devedor
                                      ,pr_qtdias_carencia  IN tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias
                                      ,pr_vlpreemp        OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                      ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
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
                                    ,pr_qtdias_carencia => pr_qtdias_carencia
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
       Data    : Maio/2017                         Ultima atualizacao: 12/04/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar o credito do emprestimo direto na conta online.

       Alteracoes: 12/04/2018 - P410 - Melhorias/Ajustes IOF (Marcos-Envolti)
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
              ,dtcarenc
              ,idcarenc
              ,idfiniof
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
              ,dsoperac
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
      rw_crapdat       BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis locais
      vr_vltottar        NUMBER := 0;
      vr_vlpreclc        NUMBER := 0;                -- Parcela calcula
      vr_vltariof        NUMBER := 0;
      vr_cdhistor        INTEGER;
      vr_cdhisgar        INTEGER;
      vr_vlrtarif        NUMBER;
      vr_vltrfesp        NUMBER;
      vr_vltrfgar        NUMBER;
      vr_cdfvlcop        INTEGER;
      vr_cdfvlgar        INTEGER;
      vr_cdlantar        craplat.cdlantar%TYPE;
      vr_flgcrcta        craplcr.flgcrcta%TYPE;
      vr_blnachou        BOOLEAN;
      vr_index_saldo     PLS_INTEGER;
      vr_vlsldisp        NUMBER;
      vr_tab_saldos      EXTR0001.typ_tab_saldos;
      vr_rowid           ROWID;
      vr_qtdias_carencia tbepr_posfix_param_carencia.qtddias%TYPE;
      vr_dsbemgar        VARCHAR2(32000);
      vr_vliofpri        NUMBER(25,2);
      vr_vliofadi        NUMBER(25,2);
      vr_flgimune        PLS_INTEGER;
      vr_nrseqdig        craplem.nrseqdig%TYPE;
      vr_floperac        BOOLEAN;
      
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
      
      -- Se for Financiamento
      vr_floperac := (rw_craplcr.dsoperac = 'FINANCIAMENTO');
      
      vr_dsbemgar := '';
      -- Percorrer todos os bens da Proposta de Emprestimo
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp) LOOP
        vr_dsbemgar := vr_dsbemgar || '|' || rw_crapbpr.dscatbem;
      END LOOP;

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
        EMPR0001.pc_cria_lancamento_cc_chave(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                            ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                            ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                            ,pr_cdbccxlt => 100           --> Numero do caixa
                                            ,pr_cdoperad => pr_cdoperad   --> Codigo do Operador
                                            ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                            ,pr_nrdolote => 8456         --> Numero do Lote
                                            ,pr_nrdconta => pr_nrdconta   --> Numero da conta
                                            ,pr_cdhistor => 15   --> Codigo historico
                                            ,pr_vllanmto => rw_crawepr.vlemprst   --> Valor de IOF
                                            ,pr_nrparepr => 0             --> Numero parcelas emprestimo
                                            ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                            ,pr_nrseqdig => vr_nrseqdig
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

      -- Busca quantidade de dias da carencia
      pc_busca_qtd_dias_carencia(pr_idcarencia => rw_crawepr.idcarenc
                                ,pr_qtddias    => vr_qtdias_carencia
                                ,pr_cdcritic   => vr_cdcritic
                                ,pr_dscritic   => vr_dscritic);
      -- Se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Calcula o IOF
      tiof0001.pc_calcula_iof_epr(pr_cdcooper        => pr_cdcooper
                                 ,pr_nrdconta        => pr_nrdconta
                                 ,pr_nrctremp        => pr_nrctremp
                                 ,pr_dtmvtolt        => pr_dtmvtolt
                                 ,pr_inpessoa        => pr_inpessoa
                                 ,pr_cdfinemp        => rw_crawepr.cdfinemp
                                 ,pr_cdlcremp        => rw_crawepr.cdlcremp
                                 ,pr_qtpreemp        => rw_crawepr.qtpreemp
                                 ,pr_vlpreemp        => rw_crawepr.vlpreemp
                                 ,pr_vlemprst        => rw_crawepr.vlemprst
                                 ,pr_dtdpagto        => rw_crawepr.dtdpagto
                                 ,pr_dtlibera        => rw_crawepr.dtlibera
                                 ,pr_tpemprst        => rw_crawepr.tpemprst
                                 ,pr_dtcarenc        => rw_crawepr.dtcarenc
                                 ,pr_qtdias_carencia => vr_qtdias_carencia
                                 ,pr_dscatbem        => vr_dsbemgar
                                 ,pr_idfiniof        => rw_crawepr.idfiniof
                                 ,pr_idgravar        => 'N'                                 
                                 ,pr_vlpreclc        => vr_vlpreclc
                                 ,pr_valoriof        => vr_vltariof
                                 ,pr_vliofpri        => vr_vliofpri
                                 ,pr_vliofadi        => vr_vliofadi
                                 ,pr_flgimune        => vr_flgimune
                                 ,pr_dscritic        => vr_dscritic);
      -- Se ocorreu erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Se possuir IOF para cobranca
      IF nvl(rw_crawepr.idfiniof,0) = 0 THEN
        -- Condicao para verificar se possui valor do IOF
        IF vr_vltariof > 0 THEN
          -- Operacao de Financiamento
          IF vr_floperac THEN
            --Codigo historico
            vr_cdhistor := 2538;
          ELSE
            --Codigo historico
            vr_cdhistor := 2537;
          END IF;
      
          -- Lanca o IOF na conta corrente do cooperado
          EMPR0001.pc_cria_lancamento_cc_chave(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                              ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                              ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                              ,pr_cdbccxlt => 100           --> Numero do caixa
                                              ,pr_cdoperad => pr_cdoperad   --> Codigo do Operador
                                              ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                              ,pr_nrdolote => 10025         --> Numero do Lote
                                              ,pr_nrdconta => pr_nrdconta   --> Numero da conta
                                              ,pr_cdhistor => vr_cdhistor   --> Codigo historico
                                              ,pr_vllanmto => vr_vltariof   --> Valor de IOF
                                              ,pr_nrparepr => 0             --> Numero parcelas emprestimo
                                              ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                              ,pr_nrseqdig => vr_nrseqdig
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
          
        END IF;
        
        -- Insere registro de pagamento de IOF na tbgen_iof_lancamento
        tiof0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                              ,pr_nrdconta     => pr_nrdconta
                              ,pr_dtmvtolt     => pr_dtmvtolt
                              ,pr_tpproduto    => 1 -- Emprestimo
                              ,pr_nrcontrato   => pr_nrctremp
                              ,pr_idlautom     => null
                              ,pr_dtmvtolt_lcm => pr_dtmvtolt
                              ,pr_cdagenci_lcm => pr_cdpactra
                              ,pr_cdbccxlt_lcm => 100
                              ,pr_nrdolote_lcm => 10025
                              ,pr_nrseqdig_lcm => vr_nrseqdig
                              ,pr_vliofpri     => vr_vliofpri
                              ,pr_vliofadi     => vr_vliofadi
                              ,pr_vliofcpl     => 0
                              ,pr_flgimune     => vr_flgimune
                              ,pr_cdcritic     => vr_cdcritic 
                              ,pr_dscritic     => vr_dscritic);

        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

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

      -- Procedure para calcular o valor da tarifa
      TARI0001.pc_calcula_tarifa(pr_cdcooper  => pr_cdcooper          --> Cooperativa conectada
                                ,pr_nrdconta  => pr_nrdconta          --> Conta do associado
                                ,pr_cdlcremp  => rw_crawepr.cdlcremp  --> Codigo da linha de credito do emprestimo.
                                ,pr_vlemprst  => rw_crawepr.vlemprst  --> Valor do Emprestimo Financiado
                                ,pr_cdusolcr  => rw_craplcr.cdusolcr  --> Codigo de uso da linha de credito (0-Normal/1-CDC/2-Boletos)
                                ,pr_tpctrato  => rw_craplcr.tpctrato  --> Tipo de contrato utilizado por esta linha de credito.
                                ,pr_dsbemgar  => vr_dsbemgar          --> Bens da Proposta
                                ,pr_cdprogra  => pr_cdprogra
                                ,pr_flgemail  => 'N'
                                ,pr_tpemprst  => 2
                                ,pr_vlrtarif  => vr_vlrtarif          --> Valor da tarifa calculada
                                ,pr_vltrfesp  => vr_vltrfesp          --> Valor da tarifa especial calculada
                                ,pr_vltrfgar  => vr_vltrfgar          --> Valor da tarifa garantia calculada                                
                                ,pr_cdhistor  => vr_cdhistor          --> Codigo do historico do lancamento.
                                ,pr_cdfvlcop  => vr_cdfvlcop          --> Codigo da faixa de valor por cooperativa.
                                ,pr_cdhisgar  => vr_cdhisgar          --> Histórico para lançamento de tarifas de bens em garantia
                                ,pr_cdfvlgar  => vr_cdfvlgar          --> Faixa de valor referente aos bens em garantia
                                ,pr_cdcritic  => vr_cdcritic          --> Critica encontrada
                                ,pr_dscritic  => vr_dscritic);        --> Texto de erro/critica encontrada
                              
      -- Total Tarifa a ser Cobrado
      vr_vltottar := NVL(vr_vlrtarif,0) + NVL(vr_vltrfesp,0);
      -- Se possuir Tarifa para cobranca
      IF vr_vltottar > 0 AND nvl(rw_crawepr.idfiniof,0) = 0 THEN
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

      -- 2 - Avaliacao de garantia de bem movel
      -- 3 - Avaliacao de garantia de bem imovel
      IF rw_craplcr.tpctrato IN (2,3) AND nvl(rw_crawepr.idfiniof,0) = 0 THEN          
        -- Se possuir saldo
        IF vr_vlsldisp > vr_vltrfgar THEN
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
                                       ,pr_cdhistor => vr_cdhisgar   -- Codigo Historico
                                       ,pr_cdpesqbb => pr_nrctremp   -- Codigo pesquisa
                                       ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                       ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                       ,pr_nrctachq => 0             -- Numero Conta Cheque
                                       ,pr_flgaviso => FALSE         -- Flag Aviso
                                       ,pr_tpdaviso => 0             -- Tipo Aviso
                                       ,pr_vltarifa => vr_vltrfgar   -- Valor tarifa
                                       ,pr_nrdocmto => pr_nrctremp   -- Numero Documento
                                       ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                       ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                       ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                       ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                       ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                       ,pr_dsidenti => NULL          -- Descricao Identificacao
                                       ,pr_cdfvlcop => vr_cdfvlgar   -- Codigo Faixa Valor Cooperativa
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
                                          ,pr_cdhistor      => vr_cdhisgar
                                          ,pr_vllanaut      => vr_vltrfgar
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
                                          ,pr_cdfvlcop      => vr_cdfvlgar
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
          vr_vlsldisp := vr_vlsldisp - vr_vltrfgar;

        END IF; -- vr_vlsldisp > vr_vlrtarif
                
      END IF; -- rw_craplcr.tpctrato = 3
      
      -- Total Tarifa a ser Cobrado
      vr_vltottar := NVL(vr_vltottar,0) + NVL(vr_vltrfgar,0);
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

  PROCEDURE pc_busca_qtd_dias_carencia(pr_idcarencia  IN tbepr_posfix_param_carencia.idcarencia%TYPE --> Codigo da Carencia
                                      ,pr_qtddias    OUT tbepr_posfix_param_carencia.qtddias%TYPE    --> Quantidade de Dias
                                      ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                       --> Codigo da critica
                                      ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS                   --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_busca_qtd_dias_carencia
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Outubro/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Busca a quantidade de dias da carencia.

       Alteracoes: 
    ............................................................................. */

    DECLARE

      -- Busca os dados
      CURSOR cr_param(pr_idcarencia IN tbepr_posfix_param_carencia.idcarencia%TYPE) IS
        SELECT qtddias
          FROM tbepr_posfix_param_carencia
         WHERE idcarencia = pr_idcarencia;

      -- Variaveis
      vr_qtddias tbepr_posfix_param_carencia.qtddias%TYPE;

    BEGIN
      OPEN  cr_param(pr_idcarencia => pr_idcarencia);
      FETCH cr_param INTO vr_qtddias;
      CLOSE cr_param;
      pr_qtddias := NVL(vr_qtddias,0);
    EXCEPTION

      WHEN OTHERS THEN
        -- Apenas retornar a variavel de saida
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure pc_busca_qtd_dias_carencia: ' || SQLERRM;

    END;

  END pc_busca_qtd_dias_carencia;
  
  PROCEDURE pc_efetua_lcto_juros_remun(pr_cdcooper IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento do Dia Anterior
                                      ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual                                      
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
                                      ,pr_insitpar IN  PLS_INTEGER DEFAULT NULL  --> Situacao da Parcela
                                      ,pr_vlsprojt IN  crapepr.vlsdeved%TYPE     --> Valor do Saldo Devedor Projetado
                                      ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando na mensal
                                      ,pr_txdiaria IN  NUMBER                    --> Taxa Diaria do Contrato
                                      ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                      ,pr_diarefju IN OUT crapepr.diarefju%TYPE     --> Dia de Referencia de Juros
                                      ,pr_mesrefju IN OUT crapepr.mesrefju%TYPE     --> Mes de Referencia do Juros
                                      ,pr_anorefju IN OUT crapepr.anorefju%TYPE     --> Ano de Referencia do Juros
                                      ,pr_vljuremu OUT NUMBER                    --> Juros Remuneratorios
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetua_lcto_juros_remun
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Julho/2017                         Ultima atualizacao: 21/01/2019

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar o lancamento de Juros Remuneratorio

       Alteracoes: 21/01/2019 - PRJ298.2.2 - Ajuste para "Atualização da Dívida após a transferência do prejuízo" - Nagasava (Supero)
    ............................................................................. */

    DECLARE
			--
			CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
											 ,pr_nrdconta IN crapepr.nrdconta%TYPE
											 ,pr_nrctremp IN crapepr.nrctremp%TYPE
											 ) IS
				SELECT crapepr.inprejuz
					FROM crapepr
				 WHERE crapepr.cdcooper = pr_cdcooper
					 AND crapepr.nrdconta = pr_nrdconta
					 AND crapepr.nrctremp = pr_nrctremp;
			--
			rw_crapepr cr_crapepr%ROWTYPE;
			--
      vr_cdhistor	      craphis.cdhistor%TYPE;

      -- Variaveis tratamento de erro
      vr_cdcritic       crapcri.cdcritic%TYPE;
      vr_dscritic       VARCHAR2(4000);
      vr_exc_erro       EXCEPTION;
    BEGIN
      -- Procedure para calcular o Juros Remuneratorio
      pc_calcula_juros_remuneratorio(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtoan => pr_dtmvtoan
                                    ,pr_dtmvtolt => pr_dtmvtolt
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_dtlibera => pr_dtlibera
                                    ,pr_dtvencto => pr_dtvencto
                                    ,pr_insitpar => pr_insitpar
                                    ,pr_vlsprojt => pr_vlsprojt
                                    ,pr_ehmensal => pr_ehmensal
                                    ,pr_txdiaria => pr_txdiaria
                                    ,pr_diarefju => pr_diarefju
                                    ,pr_mesrefju => pr_mesrefju
                                    ,pr_anorefju => pr_anorefju
                                    ,pr_vljuremu => pr_vljuremu
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Operacao de Financiamento
      IF pr_floperac THEN
        --Codigo historico
        vr_cdhistor := 2343;
      ELSE
        --Codigo historico
        vr_cdhistor := 2342;
      END IF;
			--
			OPEN cr_crapepr(pr_cdcooper
										 ,pr_nrdconta
										 ,pr_nrctremp
										 );
			--
			FETCH cr_crapepr INTO rw_crapepr;
			--
			IF cr_crapepr%NOTFOUND THEN
				--
				vr_cdcritic := 484;
				CLOSE cr_crapepr;
				RAISE vr_exc_erro;
				--
			END IF;
			--
			CLOSE cr_crapepr;
			--
			IF rw_crapepr.inprejuz = 1 THEN
				--
				vr_cdhistor := 2409;
				--
      END IF;

      -- Se possui juros
      IF pr_vljuremu > 0 THEN
        /* Cria lancamento e atualiza o lote  */
        EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                       ,pr_dtmvtolt => pr_dtmvtolt         --Data Emprestimo
                                       ,pr_cdagenci => pr_cdagenci         --Codigo Agencia
                                       ,pr_cdbccxlt => 100                 --Codigo Caixa
                                       ,pr_cdoperad => pr_cdoperad         --Operador
                                       ,pr_cdpactra => pr_cdpactra         --Posto Atendimento
                                       ,pr_tplotmov => 5                   --Tipo movimento
                                       ,pr_nrdolote => 650004              --Numero Lote
                                       ,pr_nrdconta => pr_nrdconta         --Numero da Conta
                                       ,pr_cdhistor => vr_cdhistor         --Codigo Historico
                                       ,pr_nrctremp => pr_nrctremp         --Numero Contrato
                                       ,pr_vllanmto => pr_vljuremu         --Valor Lancamento
                                       ,pr_dtpagemp => pr_dtmvtolt         --Data Pagamento Emprestimo
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
        
      END IF; -- vr_vljuros > 0

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
                                        ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento Anterior
                                        ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual
                                        ,pr_cdagenci IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                        ,pr_cdpactra IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                        ,pr_cdoperad IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                        ,pr_cdorigem IN  NUMBER                    --> Codigo da Origem
                                        ,pr_flgbatch IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                        ,pr_nrdconta IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente                                        
                                        ,pr_nrctremp IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                        ,pr_dtlibera IN  crawepr.dtlibera%TYPE     --> Data de liberacao do Contrato
                                        ,pr_dtrefjur IN  crapepr.dtrefjur%TYPE     --> Data de Referencia de Juros
                                        ,pr_diarefju IN  crapepr.diarefju%TYPE     --> Dia de Referencia de Juros
                                        ,pr_mesrefju IN  crapepr.mesrefju%TYPE     --> Mes de Referencia do Juros
                                        ,pr_anorefju IN  crapepr.anorefju%TYPE     --> Ano de Referencia do Juros
                                        ,pr_vlrdtaxa IN  NUMBER                    --> Valor da Taxa de Atualizacao da Parcela
                                        ,pr_txjuremp IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                        ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE     --> Valor da prestacao do Emprestimo
                                        ,pr_dtvencto IN  crappep.dtvencto%TYPE     --> Data de Vencimento do Contrato
                                        ,pr_insitpar IN  PLS_INTEGER DEFAULT NULL  --> Situacao da Parcela
                                        ,pr_vlsprojt IN  NUMBER                    --> Saldo Devedor Projetado
                                        ,pr_ehmensal IN  BOOLEAN                   --> Indicador se estah rodando a mensal
                                        ,pr_floperac IN  BOOLEAN                   --> Indicador se a Operacao eh Financiamento
                                        ,pr_nrparepr IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                        ,pr_dtrefcor IN  crapepr.dtrefcor%TYPE     --> Data de Referencia do ultimo lancamento de juros de correcao
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
      vr_cdhistor       craphis.cdhistor%TYPE;
      vr_qtdedias       PLS_INTEGER;
      vr_taxa_periodo   NUMBER(25,8);
      
      -- Variaveis tratamento de erro
      vr_cdcritic       crapcri.cdcritic%TYPE;
      vr_dscritic       VARCHAR2(4000);
      vr_exc_erro       EXCEPTION;
    BEGIN
      -- Procedure para calcular o Juros de Correcao
      pc_calcula_juros_correcao(pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtoan => pr_dtmvtoan
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_flgbatch => pr_flgbatch
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctremp
                               ,pr_dtlibera => pr_dtlibera
                               ,pr_dtrefjur => pr_dtrefjur
                               ,pr_vlrdtaxa => pr_vlrdtaxa
                               ,pr_dtvencto => pr_dtvencto
                               ,pr_insitpar => pr_insitpar
                               ,pr_vlsprojt => pr_vlsprojt
                               ,pr_ehmensal => pr_ehmensal
                               ,pr_dtrefcor => pr_dtrefcor
                               ,pr_vljurcor => pr_vljurcor
                               ,pr_qtdiacal => vr_qtdedias
                               ,pr_vltaxprd => vr_taxa_periodo                                     
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Operacao de Financiamento
      IF pr_floperac THEN
        --Codigo historico
        vr_cdhistor := 2345;
      ELSE
        --Codigo historico
        vr_cdhistor := 2344;
      END IF;
      
      -- Se possuir juros
      IF pr_vljurcor > 0 THEN
        /* Cria lancamento e atualiza o lote  */
        EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                       ,pr_dtmvtolt => pr_dtmvtolt         --Data Emprestimo
                                       ,pr_cdagenci => pr_cdagenci         --Codigo Agencia
                                       ,pr_cdbccxlt => 100                 --Codigo Caixa
                                       ,pr_cdoperad => pr_cdoperad         --Operador
                                       ,pr_cdpactra => pr_cdpactra         --Posto Atendimento
                                       ,pr_tplotmov => 5                   --Tipo movimento
                                       ,pr_nrdolote => 650004              --Numero Lote
                                       ,pr_nrdconta => pr_nrdconta         --Numero da Conta
                                       ,pr_cdhistor => vr_cdhistor         --Codigo Historico
                                       ,pr_nrctremp => pr_nrctremp         --Numero Contrato
                                       ,pr_vllanmto => pr_vljurcor         --Valor Lancamento
                                       ,pr_dtpagemp => pr_dtmvtolt         --Data Pagamento Emprestimo
                                       ,pr_txjurepr => pr_txjuremp         --Taxa Juros Emprestimo
                                       ,pr_vlpreemp => pr_vlpreemp         --Valor Emprestimo
                                       ,pr_nrsequni => 0                   --Numero Sequencia
                                       ,pr_nrparepr => pr_nrparepr         --Numero Parcelas Emprestimo
                                       ,pr_flgincre => TRUE                --Indicador Credito
                                       ,pr_flgcredi => TRUE                --Credito
                                       ,pr_nrseqava => 0                   --Pagamento: Sequencia do avalista
                                       ,pr_cdorigem => pr_cdorigem         -- Origem do Lançamento
                                       ,pr_qtdiacal => vr_qtdedias         -- Quantidade dias usado no calculo
                                       ,pr_vltaxprd => vr_taxa_periodo     -- Taxa no Periodo
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Erro
                                       ,pr_dscritic => vr_dscritic);       --Descricao Erro
        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
      END IF; -- vr_vljuros > 0

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
                                      ,pr_cdprogra IN  crapprg.cdprogra%TYPE     --> Nome da Tela
                                      ,pr_dtmvtoan IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento do Dia Anterior
                                      ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual
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
                                      ,pr_diarefju IN  crapepr.diarefju%TYPE     --> Dia de Referencia de Lancamento de Juros
                                      ,pr_mesrefju IN  crapepr.mesrefju%TYPE     --> Mes de Referencia de Lancamento de Juros
                                      ,pr_anorefju IN  crapepr.anorefju%TYPE     --> Ano de Referente de Lancamento de Juros
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
                                      ,pr_dtrefcor IN  crapepr.dtrefcor%TYPE     --> Data de Referencia do ultimo lancamento de juros de correcao
                                      ,pr_txmensal IN  crapepr.txmensal%TYPE     --> Taxa Mensal do Contrato
                                      ,pr_dtdstjur IN  crappep.dtdstjur%TYPE     --> Data da ultima correcao do valor pago
                                      ,pr_vlpagpar_atu IN crappep.vlpagpar%TYPE  --> Valor Ja Pago da Parcela                                      
                                      ,pr_nmdatela     IN VARCHAR2               --> Nome da tela
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetua_pagamento_em_dia
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Julho/2017                         Ultima atualizacao: 15/08/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar o Pagamento da Parcela em dia

       Alteracoes: 9318:** Pagamento de Empréstimo  Rangel Decker (AMcom)
                            Adição do parametro pr_nmdatela DEFAULT 'EMPR0011'

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
      vr_vlsdvpar NUMBER;
      vr_diarefju crapepr.diarefju%TYPE;
      vr_mesrefju crapepr.mesrefju%TYPE;
      vr_anorefju crapepr.anorefju%TYPE;
      vr_vldescto_remunert NUMBER;
      vr_vldescto_correcao NUMBER;
      
      -- Variaveis tratamento de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_des_erro VARCHAR2(1000);
      vr_exc_erro EXCEPTION;
      vr_tab_erro GENE0001.typ_tab_erro;

    BEGIN
      -- Carrega o Valor a pagar da Parcela
      vr_vlpagpar := pr_vlpagpar;
      vr_vlsdvpar := pr_vlsdvpar;
      vr_diarefju := pr_diarefju;
      vr_mesrefju := pr_mesrefju;
      vr_anorefju := pr_anorefju;
      
      -- Condicao para verificar se houve pagamento parcial da parcela e se já foi pago alguma coisa da parcela
      IF vr_vlpagpar <> vr_vlsdvpar AND pr_vlpagpar_atu > 0 THEN        
        -- Procedure para calcular a correcao do Valor Pago
        pc_calcula_correcao_valor_pago(pr_cdcooper           => pr_cdcooper
                                      ,pr_dtmvtolt           => pr_dtmvtolt
                                      ,pr_dtmvtoan           => pr_dtmvtoan
                                      ,pr_dtefetiv           => pr_dtlibera
                                      ,pr_vlpagpar           => pr_vlpagpar_atu
                                      ,pr_vlrdtaxa           => pr_vlrdtaxa
                                      ,pr_txmensal           => pr_txmensal
                                      ,pr_dtdstjur           => pr_dtdstjur
                                      ,pr_dtvencto           => pr_dtvencto
                                      ,pr_vldescto_remunert  => vr_vldescto_remunert
                                      ,pr_vldescto_correcao  => vr_vldescto_correcao
                                      ,pr_cdcritic           => vr_cdcritic
                                      ,pr_dscritic           => vr_dscritic);
                                      
        -- Condicao para verificar se houve critica
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Correcao do Saldo Devedor da Parcela
        vr_vlsdvpar := NVL(vr_vlsdvpar,0) - NVL(vr_vldescto_remunert,0) - NVL(vr_vldescto_correcao,0);
      END IF;

      -- Verifica se o valor informado para pagamento eh maior que o valor da parcela
      IF vr_vlpagpar > vr_vlsdvpar THEN
        vr_dscritic := 'Valor informado para pagamento maior que valor da parcela';
        RAISE vr_exc_erro;
      END IF;
      
      -- Efetuar o lancamento de Juros Remuneratorio
      pc_efetua_lcto_juros_remun(pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtoan => pr_dtmvtoan
                                ,pr_dtmvtolt => pr_dtmvtolt
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
                                ,pr_insitpar => 1
                                ,pr_vlsprojt => pr_vlsprojt
                                ,pr_ehmensal => pr_ehmensal
                                ,pr_txdiaria => pr_txdiaria
                                ,pr_nrparepr => pr_nrparepr
                                ,pr_diarefju => vr_diarefju
                                ,pr_mesrefju => vr_mesrefju
                                ,pr_anorefju => vr_anorefju
                              	,pr_vljuremu => vr_vljuremu
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Efetuar o lancameto de Juros de Correcao
      pc_efetua_lcto_juros_correc (pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtoan => pr_dtmvtoan
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdpactra => pr_cdpactra
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_cdorigem => pr_cdorigem
                                  ,pr_flgbatch => pr_flgbatch
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_dtlibera => pr_dtlibera
                                  ,pr_dtrefjur => pr_dtrefjur
                                  ,pr_diarefju => pr_diarefju
                                  ,pr_mesrefju => pr_mesrefju
                                  ,pr_anorefju => pr_anorefju
                                  ,pr_vlrdtaxa => pr_vlrdtaxa
                                  ,pr_txjuremp => pr_txjuremp
                                  ,pr_vlpreemp => pr_vlpreemp
                                  ,pr_dtvencto => pr_dtvencto
                                  ,pr_insitpar => 1
                                  ,pr_vlsprojt => pr_vlsprojt
                                  ,pr_ehmensal => pr_ehmensal
                                  ,pr_floperac => pr_floperac
                                  ,pr_nrparepr => pr_nrparepr
                                  ,pr_dtrefcor => pr_dtrefcor
                                  ,pr_vljurcor => vr_vljurcor
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
                                  
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Condicao para verificar se a parcela foi paga total
      IF NVL(vr_vlsdvpar,0) - NVL(vr_vlpagpar,0) <= 0 THEN
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
                                             ,pr_dtmvtolt => pr_dtmvtolt 	 --> Movimento atual
                                             ,pr_des_reto => vr_des_erro   --> Retorno OK / NOK
                                             ,pr_dscritic => vr_dscritic); --> Descricao Erro
                                             
      -- Condicao para verificar se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        vr_vlpagpar := 0;
        vr_des_erro := NULL;
        vr_dscritic := NULL;        
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
                                       ,pr_dtmvtolt => pr_dtmvtolt   -- Data Emprestimo
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
                                       ,pr_dtpagemp => pr_dtmvtolt   -- Data Pagamento Emprestimo
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
             SET crappep.dtultpag = pr_dtmvtolt
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
        
        -- No programa CRPS149: 
        -- Será feito o débito em conta corrente        
        IF UPPER(pr_cdprogra) <> 'CRPS149' AND UPPER(pr_nmdatela) <> 'BLQPREJU' THEN
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
                                        ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
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
        
        END IF;
        
        -- Atualizar Emprestimo
        BEGIN
          UPDATE crapepr
             SET crapepr.dtultpag = pr_dtmvtolt
           WHERE crapepr.cdcooper = pr_cdcooper
             AND crapepr.nrdconta = pr_nrdconta
             AND crapepr.nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crapepr. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;        

      END IF; -- vr_vlpagpar > 0
      
      -- Atualizar Emprestimo
      BEGIN
        UPDATE crapepr
           SET crapepr.dtrefjur = pr_dtmvtolt
              ,crapepr.diarefju = vr_diarefju
              ,crapepr.mesrefju = vr_mesrefju
              ,crapepr.anorefju = vr_anorefju
              ,crapepr.dtrefcor = pr_dtvencto
              ,crapepr.qtprepag = vr_qtprepag
              ,crapepr.qtprecal = vr_qtprecal
              ,crapepr.vlsdeved = NVL(crapepr.vlsdeved,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0) - NVL(vr_vlpagpar,0)
              ,crapepr.vljuratu = NVL(crapepr.vljuratu,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0)
              ,crapepr.vljuracu = NVL(crapepr.vljuracu,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0)
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

  PROCEDURE pc_efetua_pagamento_em_atraso(pr_cdcooper IN  crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                         ,pr_cdprogra IN  crapprg.cdprogra%TYPE     --> Nome da Tela
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
                                         ,pr_cdlcremp IN  crapepr.cdlcremp%TYPE     --> Linha de Credito
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
                                         ,pr_txmensal IN  crapepr.txmensal%TYPE     --> Taxa Mensal do Emprestimo
                                         ,pr_idfiniof IN  crawepr.idfiniof%TYPE     --> Indicador para financiar IOF
                                         ,pr_vlemprst IN  crapepr.vlemprst%TYPE     --> Valor do Emprestimo
                                         ,pr_nmdatela IN  VARCHAR2               --> Nome da tela
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

       Alteracoes: 9318:** Pagamento de Empréstimo  Rangel Decker (AMcom)
                            Adição do parametro pr_nmdatela DEFAULT 'EMPR0011'

                   11/10/2018 - Ajustado rotina para caso pagamento for pago pela tela
                                BLQ gerar o IOF na tabela prejuizo detalhe.
                                PRJ450 - Regulatorio(Odirlei-AMcom)         

    ............................................................................. */

    DECLARE
      -- Variaveis locais
      vr_vlmtapar            NUMBER;
      vr_vlmrapar            NUMBER;
      vr_vliofcpl            NUMBER;
      vr_vlminimo            NUMBER;
      vr_cdhistor            craphis.cdhistor%TYPE;
      vr_inliquid            crappep.inliquid%TYPE;
      vr_vljura60            crappep.vljura60%TYPE;
      vr_vlsdvatu            NUMBER;
      vr_qtprepag            NUMBER;
      vr_qtprecal            NUMBER;
      vr_vlpagpar            NUMBER;
      vr_des_reto            VARCHAR2(3);
      vr_vljuros_mora_debito craplem.vllanmto%TYPE;
      vr_nrseqdig            craplcm.nrseqdig%TYPE;

      -- Variaveis tratamento de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      vr_tab_erro GENE0001.typ_tab_erro;
      
      CURSOR cr_craplem_mora (pr_cdcooper	IN craplem.cdcooper%TYPE
                             ,pr_nrdconta IN craplem.nrdconta%TYPE
                             ,pr_nrctremp IN craplem.nrctremp%TYPE
                             ,pr_nrparepr IN craplem.nrparepr%TYPE) IS
        SELECT nvl(SUM(decode(cdhistor,
                              2373, vllanmto,
                              2371, vllanmto,
                              2377, vllanmto,
                              2375, vllanmto,
                              2347, vllanmto * -1,
                              2346, vllanmto * -1)), 0) vllanmto
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.nrparepr = pr_nrparepr
           AND craplem.cdhistor IN (2373,2371,2377,2375,2347,2346);
           
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
      -- Calcular o valor do atraso
      pc_calcula_atraso_pos_fixado(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => pr_cdprogra
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_cdlcremp => pr_cdlcremp
                                  ,pr_dtcalcul => pr_dtcalcul
                                  ,pr_vlemprst => pr_vlemprst
                                  ,pr_nrparepr => pr_nrparepr
                                  ,pr_vlparepr => pr_vlparepr
                                  ,pr_dtvencto => pr_dtvencto
                                  ,pr_dtultpag => pr_dtultpag
                                  ,pr_vlsdvpar => pr_vlsdvpar
                                  ,pr_perjurmo => pr_perjurmo
                                  ,pr_vlpagmta => pr_vlpagmta
                                  ,pr_percmult => pr_percmult
                                  ,pr_txmensal => pr_txmensal
                                  ,pr_qttolatr => pr_qttolatr
                                  ,pr_vlmrapar => vr_vlmrapar
                                  ,pr_vlmtapar => vr_vlmtapar
								                  ,pr_vliofcpl => vr_vliofcpl
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Valor Minimo para pagamento
      vr_vlminimo := NVL(vr_vlmtapar,0) + NVL(vr_vlmrapar,0) + NVL(vr_vliofcpl,0) + 0.01;
      vr_vlpagpar := NVL(pr_vlpagpar,0);
      
      -- Condicao para verificar se estah rodando no processo batch
      IF pr_flgbatch THEN
        -- Condicao para somente pagar somente o valor do atraso
        IF NVL(vr_vlpagpar,0) > (NVL(pr_vlsdvpar,0) + NVL(vr_vlmtapar,0) + NVL(vr_vlmrapar,0) + NVL(vr_vliofcpl,0)) THEN
          vr_vlpagpar := NVL(pr_vlsdvpar,0) + NVL(vr_vlmtapar,0) + NVL(vr_vlmrapar,0) + nvl(vr_vliofcpl,0);
        END IF;
        
        -- No processo noturno não será pago nada, caso não conseguir pagar o valor minimo
        IF NVL(vr_vlpagpar,0) < NVL(vr_vlminimo,0) THEN
          RETURN;
        END IF;
        
      ELSE
        -- Valor Pago da Parcela nao pode ser maior que o valor de Atraso
        IF NVL(vr_vlpagpar,0) > (NVL(pr_vlsdvpar,0) + NVL(vr_vlmtapar,0) + NVL(vr_vlmrapar,0) + nvl(vr_vliofcpl,0)) THEN
          vr_dscritic := 'Valor informado para pagamento maior que valor da parcela';
          RAISE vr_exc_erro;
        END IF;
        
        -- Valor da Parcela menor valor minimo
        IF NVL(vr_vlpagpar,0) < NVL(vr_vlminimo,0) THEN
          vr_dscritic := 'Valor a pagar deve ser maior ou igual que R$ ' || TO_CHAR(vr_vlminimo,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
          RAISE vr_exc_erro;
        END IF;
        
      END IF;
      
      -- Valor a pagar da parcela precisa diminuir o valor de Juros de Mora + Multa
      vr_vlpagpar := NVL(vr_vlpagpar,0) - NVL(vr_vlmtapar,0) - NVL(vr_vlmrapar,0) - nvl(vr_vliofcpl,0);

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
        
        -- Se for Financiamento
        IF pr_floperac THEN
          vr_cdhistor := 2349;
        ELSE
          vr_cdhistor := 2348;
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
        
        -- No programa CRPS149: 
        -- Será feito o débito em conta corrente        
        IF UPPER(pr_cdprogra) <> 'CRPS149' AND UPPER(pr_nmdatela) <> 'BLQPREJU' THEN
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
        
        vr_vljuros_mora_debito := 0;
        OPEN cr_craplem_mora(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctremp => pr_nrctremp
                            ,pr_nrparepr => pr_nrparepr);
        FETCH cr_craplem_mora INTO vr_vljuros_mora_debito;
        CLOSE cr_craplem_mora;
            
        IF vr_vljuros_mora_debito > 0 THEN
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2347;
          ELSE
            vr_cdhistor := 2346;
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
                                         ,pr_vllanmto => vr_vljuros_mora_debito  -- Valor Lancamento
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
          
        END IF;   

        -- No programa CRPS149: 
        -- Será feito o débito em conta corrente        
        IF UPPER(pr_cdprogra) <> 'CRPS149' AND UPPER(pr_nmdatela) <> 'BLQPREJU' THEN
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
        END IF;        
      END IF; -- NVL(vr_vlmrapar, 0) > 0

	    -- Efetuar o lançamento do valor complementar de IOF
      IF NVL(vr_vliofcpl, 0) > 0 THEN
        -- Se for Financiamento
        IF pr_floperac THEN
          vr_cdhistor := 2540;
        ELSE
          vr_cdhistor := 2539;
        END IF;
        
   			EMPR0001.pc_cria_lancamento_lem_chave(pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
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
                                             ,pr_vllanmto => vr_vliofcpl   -- Valor Lancamento
                                             ,pr_dtpagemp => pr_dtcalcul   -- Data Pagamento Emprestimo
                                             ,pr_txjurepr => pr_txjuremp   -- Taxa Juros Emprestimo
                                             ,pr_vlpreemp => pr_vlpreemp   -- Valor Emprestimo
                                             ,pr_nrsequni => pr_nrparepr   -- Numero Sequencia
                                             ,pr_nrparepr => pr_nrparepr   -- Numero Parcelas Emprestimo
                                             ,pr_flgincre => TRUE          -- Indicador Credito
                                             ,pr_flgcredi => TRUE          -- Credito
                                             ,pr_nrseqava => pr_nrseqava   -- Pagamento: Sequencia do avalista
                                             ,pr_cdorigem => pr_cdorigem   -- Origem do Lancamento
                                             ,pr_nrseqdig => vr_nrseqdig   -- Sequencia do Lancamento
                                             ,pr_cdcritic => vr_cdcritic   -- Codigo Erro
                                             ,pr_dscritic => vr_dscritic); -- Descricao Erro
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Insere registro de pagamento de IOF na tbgen_iof_lancamento
        tiof0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                              ,pr_nrdconta     => pr_nrdconta
                              ,pr_dtmvtolt     => pr_dtcalcul
                              ,pr_tpproduto    => 1 -- Emprestimo
                              ,pr_nrcontrato   => pr_nrctremp
                              ,pr_idlautom     => null
                              ,pr_dtmvtolt_lcm => pr_dtcalcul
                              ,pr_cdagenci_lcm => pr_cdpactra
                              ,pr_cdbccxlt_lcm => 100
                              ,pr_nrdolote_lcm => 650004
                              ,pr_nrseqdig_lcm => vr_nrseqdig
                              ,pr_vliofpri     => 0
                              ,pr_vliofadi     => 0
                              ,pr_vliofcpl     => vr_vliofcpl
                              ,pr_flgimune     => 0
                              ,pr_cdcritic     => vr_cdcritic 
                              ,pr_dscritic     => vr_dscritic);

        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Se for Financiamento
        IF pr_floperac THEN
          vr_cdhistor := 2608;
        ELSE
          vr_cdhistor := 2607;
        END IF;
        
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
                                       ,pr_vllanmto => vr_vliofcpl   -- Valor Lancamento
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
        
        --> Se for pagamento pela tela Bloqueado prejuizo
        IF upper(pr_nmdatela) = 'BLQPREJU' THEN
        
          -- Identificar numero do prejuizo da conta
          OPEN cr_contaprej(pr_cdcooper => pr_cdcooper, 
                            pr_nrdconta => pr_nrdconta);
          FETCH cr_contaprej INTO rw_contaprej;
          CLOSE cr_contaprej;
          
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2794;  --> IOF S/ FINANC
          ELSE
            vr_cdhistor := 2793; --> IOF S/EMPREST
          END IF;
                      
          -- Incluir lançamento na TBCC_PREJUIZO_DETALHE
          PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => pr_cdcooper
                                          , pr_nrdconta   => pr_nrdconta
                                          , pr_dtmvtolt   => pr_dtcalcul
                                          , pr_cdhistor   => vr_cdhistor
                                          , pr_idprejuizo => rw_contaprej.idprejuizo
                                          , pr_vllanmto   => vr_vliofcpl
                                          , pr_nrctremp   => pr_nrctremp
                                          , pr_cdoperad   => pr_cdoperad
                                          , pr_cdcritic   => vr_cdcritic
                                          , pr_dscritic   => vr_dscritic);
        
          IF nvl(vr_cdcritic,0) > 0 OR 
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro;  
          END IF;   
        
        -- No programa CRPS149: 
        -- Será feito o débito em conta corrente        
        ELSIF UPPER(pr_cdprogra) <> 'CRPS149' THEN
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2542;
          ELSE
            vr_cdhistor := 2541;
          END IF;
          
          -- Lanca em C/C e atualiza o lote
          EMPR0001.pc_cria_lancamento_cc_chave(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                              ,pr_dtmvtolt => pr_dtcalcul   --> Movimento atual
                                              ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                              ,pr_cdbccxlt => 100           --> Numero do caixa
                                              ,pr_cdoperad => pr_cdoperad   --> Codigo do operador
                                              ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                              ,pr_nrdolote => 650003        --> Numero do Lote
                                              ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                              ,pr_cdhistor => vr_cdhistor   --> Codigo historico
                                              ,pr_vllanmto => vr_vliofcpl   --> Valor da multa
                                              ,pr_nrparepr => pr_nrparepr   --> Numero parcelas emprestimo
                                              ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                              ,pr_nrseqava => pr_nrseqava   --> Pagamento: Sequencia do avalista
                                              ,pr_nrseqdig => vr_nrseqdig   --> Sequencia do Lancamento
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
              vr_dscritic := 'Erro ao criar o lancamento do IOF.';
            END IF;
            RAISE vr_exc_erro;
          END IF;        
        END IF;   	  
      
		  END IF;
  
      -- Condicao para verificar se a parcela sera liquidada
      IF NVL(pr_vlsdvpar,0) = NVL(vr_vlpagpar,0) THEN
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
              ,crappep.vlpagpar = NVL(crappep.vlpagpar,0) + NVL(vr_vlpagpar,0)
			        ,crappep.vlpagmta = NVL(crappep.vlpagmta,0) + NVL(vr_vlmtapar,0)
			        ,crappep.vlpagmra = NVL(crappep.vlpagmra,0) + NVL(vr_vlmrapar,0)
              ,crappep.vlsdvpar = NVL(crappep.vlsdvpar,0) - NVL(vr_vlpagpar,0)
              ,crappep.vlpagiof = NVL(crappep.vlpagiof,0) + NVL(vr_vliofcpl,0)
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
      
      -- No programa CRPS149: 
      -- Será feito o débito em conta corrente        
      IF UPPER(pr_cdprogra) <> 'CRPS149' AND UPPER(pr_nmdatela) <> 'BLQPREJU' THEN
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
        
      END IF;
      
      -- Atualizar Emprestimo
      BEGIN
        UPDATE crapepr
           SET crapepr.dtultpag = pr_dtcalcul
              ,crapepr.qtprepag = vr_qtprepag
              ,crapepr.qtprecal = vr_qtprecal
              ,crapepr.vlsdeved = NVL(crapepr.vlsdeved,0) - NVL(vr_vlpagpar,0)
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

  PROCEDURE pc_efetua_pagamento_vencer(pr_cdcooper  IN  crapdat.cdcooper%TYPE     --> Codigo da Cooperativa
                                      ,pr_cdprogra  IN  crapprg.cdprogra%TYPE     --> Nome da Tela
                                      ,pr_dtmvtoan  IN  crapdat.dtmvtoan%TYPE     --> Data de Movimento Anterior
                                      ,pr_dtmvtolt  IN  crapdat.dtmvtolt%TYPE     --> Data de Movimento Atual
                                      ,pr_cdagenci  IN  crapage.cdagenci%TYPE     --> Codigo da Agencia
                                      ,pr_cdpactra  IN  crapage.cdagenci%TYPE     --> Codigo da Agencia Trabalho
                                      ,pr_cdoperad  IN  crapope.cdoperad%TYPE     --> Codigo do Operador
                                      ,pr_cdorigem  IN  NUMBER                    --> Codigo da Origem
                                      ,pr_flgbatch  IN  BOOLEAN DEFAULT FALSE     --> Indica se o processo noturno estah rodando
                                      ,pr_ehmensal  IN  BOOLEAN                   --> Indicador se eh Mensal
                                      ,pr_nrdconta  IN  crapepr.nrdconta%TYPE     --> Numero da Conta Corrente
                                      ,pr_nrctremp  IN  crapepr.nrctremp%TYPE     --> Numero do Contrato
                                      ,pr_dtefetiv  IN  crapepr.dtmvtolt%TYPE     --> Data de Efetivação da Proposta
                                      ,pr_txdiaria  IN  craplcr.txdiaria%TYPE     --> Taxa Diaria
                                      ,pr_txmensal  IN  crapepr.txmensal%TYPE     --> Taxa Mensal
                                      ,pr_dtrefjur  IN  crapepr.dtrefjur%TYPE     --> Data de Referencia de Juros
                                      ,pr_diarefju  IN  crapepr.diarefju%TYPE     --> Dia de Referencia de Juros
                                      ,pr_mesrefju  IN  crapepr.mesrefju%TYPE     --> Mes de Referencia de Juros
                                      ,pr_anorefju  IN  crapepr.anorefju%TYPE     --> Ano de Referencia de Juros
                                      ,pr_txjuremp  IN  crapepr.txjuremp%TYPE     --> Taxa de Juros do Emprestimo
                                      ,pr_dtdpagto  IN  crawepr.dtdpagto%TYPE     --> Data de Pagamento da Proposta
                                      ,pr_vlsprojt  IN  crapepr.vlsprojt%TYPE     --> Saldo Projetado                                      
                                      ,pr_floperac  IN  BOOLEAN                   --> Flag do contrato de Financiamento
                                      ,pr_nrseqava  IN  PLS_INTEGER               --> Sequencia de pagamento de avalista
                                      ,pr_nrparepr  IN  crappep.nrparepr%TYPE     --> Numero da Parcela do Emprestimo
                                      ,pr_dtvencto  IN  crappep.dtvencto%TYPE     --> Data de Vencimento
                                      ,pr_vlparepr  IN  crappep.vlparepr%TYPE     --> Valor da Parcela
                                      ,pr_vlpagpar  IN  crappep.vlparepr%TYPE     --> Valor a pagar da Parcela
                                      ,pr_vlsdvpar  IN  crappep.vlsdvpar%TYPE     --> Saldo Devedor da Parcela
                                      ,pr_vltaxatu  IN  crappep.vltaxatu%TYPE     --> Taxa do CDI da Parcela
                                      ,pr_dtrefcor  IN  crapepr.dtrefcor%TYPE     --> Data de Referencia do ultimo lancamento de juros de correcao
                                      ,pr_nmdatela  IN  VARCHAR2 DEFAULT 'EMPR0011' --> Nome da tela
                                      ,pr_tab_price IN OUT typ_tab_price          --> Tab do Price                                     
                                      ,pr_inliqpep  OUT NUMBER                    --> Indica se a parcela do empréstimo foi liquidada
                                      ,pr_vlsdeved  OUT NUMBER                    --> Saldo devedor do empréstimo
                                      ,pr_cdcritic  OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                      ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
  BEGIN
    /* .............................................................................

       Programa: pc_efetua_pagamento_vencer
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Julho/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar o pagamento da parcela a Vencer

       Alteracoes: 9318:** Pagamento de Empréstimo  Rangel Decker (AMcom)
                            Adição do parametro pr_nmdatela DEFAULT 'EMPR0011'

    ............................................................................. */

    DECLARE
    	vr_vlatupar   NUMBER(25,2);
      vr_vldescto   NUMBER(25,2);
      vr_vljuremu   NUMBER(25,2);
      vr_vljurcor   NUMBER(25,2);
      vr_diarefju   crapepr.diarefju%TYPE;
      vr_mesrefju   crapepr.mesrefju%TYPE;
      vr_anorefju   crapepr.anorefju%TYPE;
      vr_vlsdvpar   crappep.vlsdvpar%TYPE;
      vr_inliquid   crappep.inliquid%TYPE;
      vr_cdhistor   craphis.cdhistor%TYPE;
    
      -- Variaveis tratamento de erros
      vr_tab_erro   GENE0001.typ_tab_erro;
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      vr_des_reto   VARCHAR2(3);
      vr_exc_erro   EXCEPTION;

    BEGIN
	    -- Efetua o calculo da antecipacao da parcela
      pc_calcula_desconto_pos(pr_dtcalcul  => pr_dtmvtolt
                             ,pr_flgbatch  => pr_flgbatch
                             ,pr_cdcooper  => pr_cdcooper
                             ,pr_dtefetiv  => pr_dtefetiv
                             ,pr_txmensal  => pr_txmensal
                             ,pr_dtdpagto  => pr_dtdpagto
                             ,pr_vlsprojt  => pr_vlsprojt
                             ,pr_nrparepr  => pr_nrparepr
                             ,pr_dtvencto  => pr_dtvencto
                             ,pr_vlsdvpar  => pr_vlsdvpar
                             ,pr_vltaxatu  => pr_vltaxatu
                             ,pr_tab_price => pr_tab_price
                             ,pr_vlatupar  => vr_vlatupar
                             ,pr_vldescto  => vr_vldescto
                             ,pr_cdcritic  => vr_cdcritic
                             ,pr_dscritic  => vr_dscritic);
      
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Verificar Valor Informado e Valor da Parcela
      IF NVL(pr_vlpagpar,0) > NVL(vr_vlatupar,0) THEN
        -- Mensagem Erro
        vr_dscritic := 'Valor informado para pagamento maior que valor da parcela.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Pagamento Parcial nao permitido
      IF pr_dtdpagto > pr_dtvencto THEN
        -- Mensagem Erro
        vr_dscritic := 'Pagamento parcial nao permitido.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Condicao para verificar se foi pago parcial
      IF nvl(pr_vlpagpar,0) <> nvl(vr_vlatupar,0) THEN
        -- Calculo do desconto parcial
        pc_calcula_descto_pos_parcial(pr_cdcooper => pr_cdcooper -- Codigo da Cooperativa
                                     ,pr_dtmvtolt => pr_dtmvtolt -- Data de Movimento
                                     ,pr_nrdconta => pr_nrdconta -- Numero da Conta Corrente
                                     ,pr_nrctremp => pr_nrctremp -- Numero do Contrato
                                     ,pr_nrparepr => pr_nrparepr -- Parcela
                                     ,pr_vlpagpar => pr_vlpagpar -- Valor Pago Parcela
                                     ,pr_vldescto => vr_vldescto -- Desconto da Parcela
                                     ,pr_cdcritic => vr_cdcritic -- Codigo da Critica
                                     ,pr_dscritic => vr_dscritic);
        
        -- Condicao para verificar se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
      END IF;
      
      ---------------------------------------------------------------------------------------------------
      -- Efetua o lancamento de Juros de Remuneratorio
      ---------------------------------------------------------------------------------------------------
      vr_diarefju := pr_diarefju;
      vr_mesrefju := pr_mesrefju;
      vr_anorefju := pr_anorefju;
      
      pc_efetua_lcto_juros_remun(pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtoan => pr_dtmvtoan
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdpactra => pr_cdpactra
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_cdorigem => pr_cdorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_txjuremp => pr_txjuremp
                                ,pr_vlpreemp => pr_vlsdvpar
                                ,pr_dtlibera => pr_dtefetiv
                                ,pr_dtrefjur => pr_dtrefjur
                                ,pr_floperac => pr_floperac
                                ,pr_dtvencto => pr_dtvencto
                                ,pr_insitpar => 3
                                ,pr_vlsprojt => pr_vlsprojt
                                ,pr_ehmensal => pr_ehmensal
                                ,pr_txdiaria => pr_txdiaria
                                ,pr_nrparepr => pr_nrparepr
                                ,pr_diarefju => vr_diarefju
                                ,pr_mesrefju => vr_mesrefju
                                ,pr_anorefju => vr_anorefju
                              	,pr_vljuremu => vr_vljuremu
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      ---------------------------------------------------------------------------------------------------
      -- Efetua o lancamento de Juros de Correcao
      ---------------------------------------------------------------------------------------------------
      pc_efetua_lcto_juros_correc (pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtoan => pr_dtmvtoan
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdpactra => pr_cdpactra
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_cdorigem => pr_cdorigem
                                  ,pr_flgbatch => pr_flgbatch
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_dtlibera => pr_dtefetiv
                                  ,pr_dtrefjur => pr_dtrefjur
                                  ,pr_diarefju => pr_diarefju
                                  ,pr_mesrefju => pr_mesrefju
                                  ,pr_anorefju => pr_anorefju                                  
                                  ,pr_vlrdtaxa => pr_vltaxatu
                                  ,pr_txjuremp => pr_txjuremp
                                  ,pr_vlpreemp => pr_vlparepr
                                  ,pr_dtvencto => pr_dtvencto
                                  ,pr_insitpar => 3
                                  ,pr_vlsprojt => pr_vlsprojt
                                  ,pr_ehmensal => pr_ehmensal
                                  ,pr_floperac => pr_floperac
                                  ,pr_nrparepr => pr_nrparepr
                                  ,pr_dtrefcor => pr_dtrefcor
                                  ,pr_vljurcor => vr_vljurcor
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
                                  
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      ---------------------------------------------------------------------------------------------------
      -- Efetua o lancamento de Pagamento no Emprestimo
      ---------------------------------------------------------------------------------------------------
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
              
      /* Cria lancamento e atualiza o lote */
      EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                     ,pr_dtmvtolt => pr_dtmvtolt         --Data Emprestimo
                                     ,pr_cdagenci => pr_cdagenci         --Codigo Agencia
                                     ,pr_cdbccxlt => 100                 --Codigo Caixa
                                     ,pr_cdoperad => pr_cdoperad         --Operador
                                     ,pr_cdpactra => pr_cdpactra         --Posto Atendimento
                                     ,pr_tplotmov => 5                   --Tipo movimento
                                     ,pr_nrdolote => 650004              --Numero Lote
                                     ,pr_nrdconta => pr_nrdconta         --Numero da Conta
                                     ,pr_cdhistor => vr_cdhistor         --Codigo Historico
                                     ,pr_nrctremp => pr_nrctremp         --Numero Contrato
                                     ,pr_vllanmto => pr_vlpagpar         --Valor Lancamento
                                     ,pr_dtpagemp => pr_dtmvtolt         --Data Pagamento Emprestimo
                                     ,pr_txjurepr => pr_txjuremp         --Taxa Juros Emprestimo
                                     ,pr_vlpreemp => pr_vlparepr         --Valor Emprestimo
                                     ,pr_nrsequni => 0                   --Numero Sequencia
                                     ,pr_nrparepr => pr_nrparepr         --Numero Parcelas Emprestimo
                                     ,pr_flgincre => TRUE                --Indicador Credito
                                     ,pr_flgcredi => TRUE                --Credito
                                     ,pr_nrseqava => pr_nrseqava         --Pagamento: Sequencia do avalista
                                     ,pr_cdorigem => pr_cdorigem         -- Origem do Lançamento
                                     ,pr_cdcritic => vr_cdcritic         --Codigo Erro
                                     ,pr_dscritic => vr_dscritic);       --Descricao Erro
      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
	
      ---------------------------------------------------------------------------------------------------
      -- Efetua o lancamento de Desconto de Pagamento no Emprestimo
      ---------------------------------------------------------------------------------------------------
      IF NVL(vr_vldescto,0) > 0 THEN
        -- Se for Financiamento
        IF pr_floperac THEN
          vr_cdhistor := 2566;
        ELSE
          vr_cdhistor := 2567;
        END IF;

        /* Cria lancamento e atualiza o lote */
        EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                                       ,pr_dtmvtolt => pr_dtmvtolt         --Data Emprestimo
                                       ,pr_cdagenci => pr_cdagenci         --Codigo Agencia
                                       ,pr_cdbccxlt => 100                 --Codigo Caixa
                                       ,pr_cdoperad => pr_cdoperad         --Operador
                                       ,pr_cdpactra => pr_cdpactra         --Posto Atendimento
                                       ,pr_tplotmov => 5                   --Tipo movimento
                                       ,pr_nrdolote => 650004              --Numero Lote
                                       ,pr_nrdconta => pr_nrdconta         --Numero da Conta
                                       ,pr_cdhistor => vr_cdhistor         --Codigo Historico
                                       ,pr_nrctremp => pr_nrctremp         --Numero Contrato
                                       ,pr_vllanmto => vr_vldescto         --Valor Lancamento
                                       ,pr_dtpagemp => pr_dtmvtolt         --Data Pagamento Emprestimo
                                       ,pr_txjurepr => pr_txjuremp         --Taxa Juros Emprestimo
                                       ,pr_vlpreemp => pr_vlparepr         --Valor Emprestimo
                                       ,pr_nrsequni => 0                   --Numero Sequencia
                                       ,pr_nrparepr => pr_nrparepr         --Numero Parcelas Emprestimo
                                       ,pr_flgincre => TRUE                --Indicador Credito
                                       ,pr_flgcredi => TRUE                --Credito
                                       ,pr_nrseqava => pr_nrseqava         --Pagamento: Sequencia do avalista
                                       ,pr_cdorigem => pr_cdorigem         -- Origem do Lançamento
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Erro
                                       ,pr_dscritic => vr_dscritic);       --Descricao Erro
        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;  

      ---------------------------------------------------------------------------------------------------
      -- Efetua o lancamento de Pagamento em Conta Corrente
      ---------------------------------------------------------------------------------------------------
      -- No programa CRPS149: 
      -- Será feito o débito em conta corrente        
      IF UPPER(pr_cdprogra) <> 'CRPS149' AND UPPER(pr_nmdatela) <> 'BLQPREJU' THEN
        IF NVL(pr_nrseqava,0) = 0 THEN
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2333;
          ELSE
            vr_cdhistor := 2332;
          END IF;
        ELSE
          -- Se for Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2337;
          ELSE
            vr_cdhistor := 2336;
          END IF;
        END IF;
        
        -- Lanca em C/C e atualiza o lote
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                      ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                      ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                      ,pr_cdbccxlt => 100           --> Numero do caixa
                                      ,pr_cdoperad => pr_cdoperad   --> Codigo do operador
                                      ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                      ,pr_nrdolote => 650003        --> Numero do Lote
                                      ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                      ,pr_cdhistor => vr_cdhistor   --> Codigo historico
                                      ,pr_vllanmto => pr_vlpagpar   --> Valor da parcela emprestimo
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

      END IF;
      
    	-- Verificar valor saldo devedor parcela
      vr_vlsdvpar := nvl(pr_vlsdvpar,0) - (nvl(pr_vlpagpar,0) + nvl(vr_vldescto,0));
      IF vr_vlsdvpar <= 0 THEN
        vr_vlsdvpar := 0;
      END IF;
      
      -- Verificar se liquidou a parcela
      vr_inliquid := CASE nvl(vr_vlsdvpar,0) WHEN 0 THEN 1 ELSE 0 END;
      
      -- Retornar se a parcela foi ou não liquidada
      pr_inliqpep := vr_inliquid;
      
      --Atualizar Informacoes Parcelas
      BEGIN
        UPDATE crappep SET 
               crappep.vldespar = nvl(crappep.vldespar,0) + nvl(vr_vldescto,0)
              ,crappep.dtultpag = pr_dtmvtolt
              ,crappep.vlpagpar = nvl(crappep.vlpagpar,0) + nvl(pr_vlpagpar,0)
              ,crappep.vlsdvpar = vr_vlsdvpar
              ,crappep.inliquid = vr_inliquid
              ,crappep.vlsdvatu = DECODE(crappep.inliquid,1,0,crappep.vlsdvatu)
              ,crappep.vljura60 = DECODE(crappep.inliquid,1,0,crappep.vljura60)
              ,crappep.dtdstjur = pr_dtmvtolt
        WHERE crappep.cdcooper = pr_cdcooper
          AND crappep.nrdconta = pr_nrdconta
          AND crappep.nrctremp = pr_nrctremp
          AND crappep.nrparepr = pr_nrparepr;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crappep. '||sqlerrm;
          RAISE vr_exc_erro;  
      END;	
	    
      -- Atualiza o emprestimo
      BEGIN
        UPDATE crapepr SET crapepr.dtultpag = pr_dtmvtolt
                          ,crapepr.qtprepag = nvl(crapepr.qtprepag,0) + nvl(vr_inliquid,0)
                          ,crapepr.qtprecal = nvl(crapepr.qtprecal,0) + nvl(vr_inliquid,0)
                          ,crapepr.vlsdeved = nvl(crapepr.vlsdeved,0) + nvl(vr_vljuremu,0) + nvl(vr_vljurcor,0) - nvl(pr_vlpagpar,0)
                          ,crapepr.vljuratu = nvl(crapepr.vljuratu,0) + nvl(vr_vljuremu,0) + nvl(vr_vljurcor,0)
                          ,crapepr.vljuracu = nvl(crapepr.vljuracu,0) + nvl(vr_vljuremu,0) + nvl(vr_vljurcor,0)
                          ,crapepr.dtrefjur = pr_dtmvtolt
                          ,crapepr.diarefju = vr_diarefju
                          ,crapepr.mesrefju = vr_mesrefju
                          ,crapepr.anorefju = vr_anorefju
                          ,crapepr.dtrefcor = pr_dtmvtolt
        WHERE crapepr.cdcooper = pr_cdcooper
          AND crapepr.nrdconta = pr_nrdconta
          AND crapepr.nrctremp = pr_nrctremp
        RETURNING vlsdeved INTO pr_vlsdeved; -- Retornar o saldo
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapepr. '||sqlerrm;
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := NVL(vr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
              
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na procedure EMPR0011.pc_efetua_pagamento_vencer: ' || SQLERRM;
    END;

  END pc_efetua_pagamento_vencer;

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
       Data    : Julho/2017                         Ultima atualizacao: 11/06/2019

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar a validacao dos pagamentos.

       Alteracoes: 11/06/2019 - Não permitir liquidar contrato Pós-Fixado no mesmo dia em que foi feita a liberação
                                Retirada condição de verificação de refinanciamento P_298.3 (Darlei / Supero)
    
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
      -- E se for Refinanciamento -- Retirada esta condição (Darlei / Supero)
      -- Não permitir liquidar contrato Pós-Fixado no mesmo dia em que foi feita a liberação
      IF pr_rw_crapdat.dtmvtolt = pr_dtlibera THEN
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
       Data    : Julho/2017                         Ultima atualizacao: 28/09/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetuar a validacao dos pagamentos.

       Alteracoes: 28/09/2018 - Alterado de local a chamada da rotina RECP0001.pc_verifica_acordo_ativo, pois quando o saldo era insuficiente, nao validava o acordo (Adriano Nagasava - Supero)
    ............................................................................. */

    DECLARE
      -- Cursor da proposta de emprestimo
      CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT tpemprst
              ,dtlibera
              ,dtdpagto              
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
      
      /*
      -- Busca as parcelas para pagamento
      pc_busca_pagto_parc_pos(pr_cdcooper => vr_cdcooper
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_dtefetiv => rw_crapepr.dtmvtolt
                             ,pr_cdlcremp => rw_crapepr.cdlcremp
                             ,pr_vlemprst => rw_crapepr.vlemprst
                             ,pr_txmensal => rw_crapepr.txmensal
                             ,pr_dtdpagto => rw_crapepr.dtdpagto
                             ,pr_vlsprojt => rw_crapepr.vlsprojt
                             ,pr_qttolatr => rw_crapepr.qttolatr
                             ,pr_tab_parcelas => vr_tab_parcelas
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);                     
                             
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      */
      
      /*
      -- Bloquear para não permitir antecipar uma parcela total do Juros da Carência
      IF TOTAL_VALOR_ATUAL <> TOTAL_PAGAR THEN
        
        -- Loop das parcelas selecionados em tela
        LOOP PARCELAS_TELA FOR          
          -- Condicao para verificar se estamos antecipando a parcela do Juros da Carencia
          IF TEMP-TABLE.dtvencto < rw_crawepr.dtdpagto THEN
            vr_dscritic := 'Nao e possivel antecipar parcela juros da carencia';
            RAISE vr_exc_erro;
          END IF;        
        END LOOP;
        
      END IF;
      */

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

  -- Rotina destinada a geração dos dados de antecipação para o MITRA
  PROCEDURE pc_mitra_gera_antecipacao(pr_cdcooper    IN tbepr_mitra_pagamento.cdcooper%TYPE
                                     ,pr_nrdconta    IN tbepr_mitra_pagamento.nrdconta%TYPE
                                     ,pr_nrctremp    IN tbepr_mitra_pagamento.nrctremp%TYPE
                                     ,pr_vlsdeved    IN tbepr_mitra_pagamento.vlsaldo_devedor%TYPE
                                     ,pr_vlrpagto    IN tbepr_mitra_pagamento.vlantecipacao%TYPE
                                     ,pr_nrpeppag    IN tbepr_mitra_pagamento.nrparcela_antecip%TYPE
                                     ,pr_inliqpep    IN NUMBER
                                     ,pr_dscritic   OUT VARCHAR2) IS
    
    /* .............................................................................

       Programa: pc_mitra_gera_antecipacao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Renato Darosci
       Data    : Abril/2019                         Ultima atualizacao: 08/05/2019

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para gerar os dados de antecipação 

       Alteracoes: 
       
              08/05/2019 - Ajustar o calculo da taxa de amortização para as novas
                           parcelas geradas pela antecipação (Renato Darosci - Supero)
    ............................................................................. */
  
    -- Buscar o novo id para geração dos dados
    CURSOR cr_idantecip IS
      SELECT NVL(MAX(t.idantecipacao),0) + 1
        FROM tbepr_mitra_pagamento t;
    
    -- Buscar a ultima antecipação criada para o contrato
    CURSOR cr_last_antecip IS 
      SELECT t.idantecipacao
           , t.dsindentificador
        FROM tbepr_mitra_pagamento t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.nrctremp = pr_nrctremp
       ORDER BY t.dtantecipacao DESC
              , LENGTH(t.dsindentificador) DESC
              , t.dsindentificador DESC;
    rg_last_antecip     cr_last_antecip%ROWTYPE;
    
    -- Buscar dados do empréstimo
    CURSOR cr_crqtdpep IS
      SELECT epr.dtdpagto
           , COUNT(pep.nrparepr)  qtparepr
        FROM crawepr  epr
           , crappep  pep
       WHERE epr.cdcooper = pep.cdcooper
         AND epr.nrdconta = pep.nrdconta
         AND epr.nrctremp = pep.nrctremp
         AND pep.cdcooper = pr_cdcooper
         AND pep.nrdconta = pr_nrdconta
         AND pep.nrctremp = pr_nrctremp
       GROUP BY epr.dtdpagto;
    rg_crqtdpep   cr_crqtdpep%ROWTYPE;
    
    -- Buscar todas as parcelas não liquidadas do emprestimo
    CURSOR cr_crappep IS
      SELECT ROWNUM  nrparnew
           , pep.nrparepr
           , pep.dtvencto
           , pep.vltaxatu  vlamortz -- Será calculado no registro da antecipação
           , pep.inliquid
        FROM crappep  pep
       WHERE pep.cdcooper = pr_cdcooper
         AND pep.nrdconta = pr_nrdconta
         AND pep.nrctremp = pr_nrctremp
         AND pep.inliquid = 0 -- não liquidadas
       ORDER BY pep.dtvencto ASC;
        
    -- Variáveis
    TYPE typ_tab_crappep IS TABLE OF cr_crappep%ROWTYPE INDEX BY BINARY_INTEGER;
    vr_tbparcel     typ_tab_crappep;
    vr_idanteci     tbepr_mitra_pagamento.idantecipacao%TYPE;
    vr_dsantepr     tbepr_mitra_pagamento.dsindentificador%TYPE;
    vr_cdascant     NUMBER;
    vr_qtcaract     NUMBER;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);
    vr_vldataxa     NUMBER;
    vr_tpamortz     NUMBER;
    vr_vlamortz     NUMBER;
    vr_dtanteci     DATE;
    
    vr_exc_erro     EXCEPTION;
  BEGIN
  
    -- Buscar data do sistema
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
    
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      
      vr_dscritic := gene0001.fn_busca_critica(1);
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar o Cursor
    CLOSE btch0001.cr_crapdat;
  
     -- Percorrer todas as parcelas que não foram liquidadas
    FOR rg_crappep IN cr_crappep LOOP
      -- Adiciona as parcelas no registro de memória
      vr_tbparcel(rg_crappep.nrparnew) := rg_crappep;   
    END LOOP;
    
    -- Se não encontrar parcelas para gerar adiantamento
    IF vr_tbparcel.COUNT() = 0 THEN
      -- Sai da rotina, pois não há antecipação para gerar
      RETURN;
    END IF;  
  
    -- Buscar a ultima antecipação registrada
    OPEN  cr_last_antecip;
    FETCH cr_last_antecip INTO rg_last_antecip; --vr_dsantepr;
    
    -- Se nenhum registro foi encontrado, deve assumir "A" como valor inicial
    -- O registro será sempre realizado em maiúsculo, apesar de no momento da escritar
    -- será utilizado minusculo.
    IF cr_last_antecip%NOTFOUND THEN
      
      -- Fechar o cursor
      CLOSE cr_last_antecip;
    
      vr_dsantepr := 'A';
      
    ELSE
      
      -- Fechar o cursor
      CLOSE cr_last_antecip; 
     
      /*** REALIZA O CALCULO DO PRÓXIMO DÍGITO A SER UTILIZADO ***/
      -- Ler o código asc do caracter (APENAS O PRIMEIRO)
      vr_cdascant := ASCII(SUBSTR(rg_last_antecip.dsindentificador,1,1));
      
      -- Guardar a quantidade de caracteres existes 
      vr_qtcaract := LENGTH(rg_last_antecip.dsindentificador);
      
      -- Deve ser incrementado o caracter, sendo assim A será B, B será C... etc
      vr_cdascant := vr_cdascant + 1;
      
      -- Se chegar ao 91, quer dizer que passou de Z
      IF vr_cdascant > 90 THEN
        -- Deve voltar a utilizar "A"
        vr_cdascant := 65;
        
        -- Incrementa a quantidade de caracteres
        vr_qtcaract := NVL(vr_qtcaract,0) + 1;
      END IF;
      
      -- Forma o identificador 
      vr_dsantepr := RPAD(CHR(vr_cdascant),vr_qtcaract,CHR(vr_cdascant));
      
    END IF;
    
    -- Amortização
    vr_vlamortz := 0;
    
    -- Buscar a quantidade total de parcelas do empréstimo
    OPEN  cr_crqtdpep;
    FETCH cr_crqtdpep INTO rg_crqtdpep;
    CLOSE cr_crqtdpep;
    
    -- Percorrer as parcelas do empréstimo não liquidadas
    IF vr_tbparcel.COUNT > 0 THEN
      -- Percorre para calcular as taxas e totalizar
      FOR ind IN vr_tbparcel.FIRST..vr_tbparcel.LAST LOOP
        -- Percorer
        IF vr_tbparcel(ind).dtvencto >= rg_crqtdpep.dtdpagto THEN
          -- Calcular o valor da amortização 
          vr_tbparcel(ind).vlamortz := /*ROUND(*/(1 / rg_crqtdpep.qtparepr)/*, 9)*/;
        ELSE
          vr_tbparcel(ind).vlamortz := 0;
        END IF;
        
        -- Quando for uma parcela ainda não liquidada
        IF vr_tbparcel(ind).inliquid = 0 THEN
          -- Somar o valor total
          vr_vlamortz := vr_vlamortz + vr_tbparcel(ind).vlamortz;
        END IF;
        
      END LOOP;
      
      -- Percorre novamente para calcular a taxa para a antecipação
      FOR ind IN vr_tbparcel.FIRST..vr_tbparcel.LAST LOOP
        -- Calcular o valor da amortização 
        vr_tbparcel(ind).vlamortz := /*ROUND(*/(vr_tbparcel(ind).vlamortz / vr_vlamortz)/*, 9)*/;
      END LOOP;
      
    END IF;
        
    -- Verifica o tipo de amortização a ser registrado
    -- Se a parcela paga, foi liquidada
    IF pr_inliqpep = 1 THEN
      vr_tpamortz := 2; -- Total
    ELSE
      vr_tpamortz := 1; -- Parcial
    END IF;
    
    -- Buscar o próximo id para ser utilizado
    OPEN  cr_idantecip;
    FETCH cr_idantecip INTO vr_idanteci;
    CLOSE cr_idantecip;
        
    BEGIN
      vr_dtanteci := to_date(to_char(btch0001.rw_crapdat.dtmvtolt,'DD/MM/YYYY')||' '||
                             to_char(SYSDATE,'HH24:MI:SS'),'DD/MM/YYYY HH24:MI:SS');
    
      -- Insere o cabeçalho da antecipação gerada
      INSERT INTO tbepr_mitra_pagamento
                         (idantecipacao
                         ,cdcooper
                         ,nrdconta
                         ,nrctremp
                         ,dsindentificador
                         ,dtantecipacao
                         ,vlsaldo_devedor
                         ,tppagamento
                         ,tpamortizacao
                         ,vlantecipacao
                         ,nrparcela_antecip)
                  VALUES (vr_idanteci         -- idantecipacao
                         ,pr_cdcooper         -- cdcooper
                         ,pr_nrdconta         -- nrdconta
                         ,pr_nrctremp         -- nrctremp
                         ,vr_dsantepr         -- dsindentificador
                         ,vr_dtanteci         -- dtantecipacao
                         ,pr_vlsdeved         -- vlsaldo_devedor
                         ,1                   -- tppagamento -- Postecipado
                         ,vr_tpamortz         -- tpamortizacao -- Total / Parcial
                         ,pr_vlrpagto         -- vlantecipacao
                         ,pr_nrpeppag);       -- nrparcela_antecip
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao incluir dados para o MITRA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Calcula a taxa conforme a quantidade de parcelas
    -- vr_vldataxa := (1 / vr_tbparcel.COUNT());
    
    -- Para cara uma das parcelas, realizar o calculo da taxa e gravar na tabela
    FOR ind IN vr_tbparcel.FIRST..vr_tbparcel.LAST LOOP
      -- Calcular a nova taxa de amortização para a parcela
      --vr_tbparcel(ind).txamortiz := vr_vldataxa;
    
      BEGIN
        -- Inserir o registro da parcela
        INSERT INTO tbepr_mitra_pagamento_parcela
                      (idantecipacao
                      ,nrnova_parcela
                      ,nrparepr
                      ,txamortizacao)
                VALUES(vr_idanteci                  -- idantecipacao
                      ,vr_tbparcel(ind).nrparnew    -- nrnova_parcela
                      ,vr_tbparcel(ind).nrparepr    -- nrparepr
                      ,vr_tbparcel(ind).vlamortz); -- txamortizacao
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao incluir dados das parcelas para o MITRA: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP; 
    
    -- Limpar a collection
    vr_tbparcel.DELETE;
        
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Apenas retornar a variável de saida
      IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      
      -- retornar a mensagem de erro
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Apenas retornar a variável de saida
      pr_dscritic := 'Erro na procedure PC_MITRA_GERA_ANTECIPACAO: ' || SQLERRM;
  END pc_mitra_gera_antecipacao;
  
  
  
  PROCEDURE pc_gera_pagto_pos(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                             ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Codigo do Programa
                             ,pr_dtcalcul  IN crapdat.dtmvtolt%TYPE --> Data de calculo das parcelas
                             ,pr_flgbatch  IN BOOLEAN DEFAULT FALSE --> Definir se estah rodando o pagamento no batch
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                             ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero do contrato
                             ,pr_nrparepr  IN crappep.nrparepr%TYPE --> Numero da parcela
                             ,pr_vlpagpar  IN crappep.vlparepr%TYPE --> Valor para pagamento da parcela
                             ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Sequencia do titular
                             ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo da Agencia
                             ,pr_cdpactra  IN crapage.cdagenci%TYPE --> Codigo da Agencia Trabalho
                             ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE --> Numero do caixa
                             ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                             ,pr_nrseqava  IN PLS_INTEGER           --> Sequencia de pagamento de avalista
                             ,pr_idorigem  IN PLS_INTEGER           --> Codigo de origem
                             ,pr_nmdatela  IN VARCHAR2              --> Nome da tela
                             ,pr_tab_price IN OUT typ_tab_price     --> Temp-Table contendo o o Price de Desconto das Parcelas
                             ,pr_cdcritic  OUT PLS_INTEGER          --> Codigo da critica
                             ,pr_dscritic  OUT VARCHAR2) IS         --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_gera_pagto_pos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Outubro/2017                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para geracao dos pagamentos.

       Alteracoes:  9318:** Pagamento de Empréstimo  Rangel Decker (AMcom)
                         Alteração nas chamadas da procedures :
                         -

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
              ,crapepr.dtmvtolt
              ,crapepr.dtultpag
              ,crawepr.dtlibera
              ,crawepr.cddindex
              ,crapepr.diarefju
              ,crapepr.mesrefju
              ,crapepr.anorefju
              ,crapepr.dtrefcor
              ,crawepr.dtdpagto
              ,crawepr.idfiniof
              ,crapepr.vlemprst
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

      -- Cursor da parcelas dos Emprestimo
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE
                       ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT crappep.nrparepr
              ,crappep.inliquid
              ,crappep.dtvencto
              ,crappep.vlsdvpar
              ,crappep.vlsdvatu
              ,crappep.vljura60
              ,crappep.dtultpag
              ,crappep.vlparepr
              ,crappep.vlpagmta
              ,crappep.vltaxatu
              ,crappep.dtdstjur
              ,crappep.vlpagpar
              ,crappep.vldstrem
              ,crappep.vldstcor
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
                       ,pr_nrparepr IN crappep.nrparepr%TYPE
                       ,pr_dtvencto IN crappep.dtvencto%TYPE) IS
        SELECT 1
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr < pr_nrparepr
           AND crappep.inliquid = 0
           AND crappep.dtvencto < pr_dtvencto;
      rw_pep_ant cr_pep_ant%ROWTYPE;
      
      -- Verifica se as parcelas informadas estão em ordem			
			CURSOR cr_crappep_ordem1(pr_cdcooper IN crappep.cdcooper%TYPE
                              ,pr_nrdconta IN crappep.nrdconta%TYPE
                              ,pr_nrctremp IN crappep.nrctremp%TYPE
                              ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
			  SELECT 1
				  FROM crappep pep
				 WHERE pep.cdcooper = pr_cdcooper
				   AND pep.nrdconta = pr_nrdconta
					 AND pep.nrctremp = pr_nrctremp
					 AND pep.nrparepr > pr_nrparepr
					 AND pep.inliquid = 0;
			rw_crappep_ordem1 cr_crappep_ordem1%ROWTYPE;
							 
		  -- Verifica se as parcelas informadas estão em ordem			
			CURSOR cr_crappep_ordem2(pr_cdcooper IN crappep.cdcooper%TYPE
                              ,pr_nrdconta IN crappep.nrdconta%TYPE
                              ,pr_nrctremp IN crappep.nrctremp%TYPE
                              ,pr_nrparepr IN crappep.nrparepr%TYPE)IS
			  SELECT 1
				  FROM crappep pep
				 WHERE pep.cdcooper = pr_cdcooper
				   AND pep.nrdconta = pr_nrdconta
					 AND pep.nrctremp = pr_nrctremp
					 AND pep.nrparepr < pr_nrparepr
					 AND pep.inliquid = 0;
			rw_crappep_ordem2 cr_crappep_ordem2%ROWTYPE;
    
      -- Registro tipo Data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
      -- Variaveis Locais
      vr_dtmvtolt           DATE;
      vr_dtmvtoan           DATE;
      vr_dtmvtopr           DATE;
      vr_blnachou           BOOLEAN;
      vr_floperac           BOOLEAN;
      vr_flmensal           BOOLEAN;
      vr_txdiaria           craplcr.txdiaria%TYPE;
      vr_dsorigem           VARCHAR2(50);
      vr_nrdrowid           ROWID;
      vr_dstextab           craptab.dstextab%TYPE;
      vr_percmult           NUMBER(25,2);
      vr_blnachou_ordem1    BOOLEAN;
      vr_blnachou_ordem2    BOOLEAN;
    
      -- Renato Darosci (Supero) - 29/04/2019
      vr_vlsdeved           NUMBER; -- Guardar o saldo devedor retornado 
      vr_inliqpep           NUMBER; -- Guardar o flag que indica liquidação da parcela paga
      
      -- Variaveis Erro
      vr_cdcritic           INTEGER;
      vr_dscritic           VARCHAR2(4000);
    
      -- Variaveis Excecao
      vr_exc_erro           EXCEPTION;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_pagto_pos'
                                ,pr_action => NULL);

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

      -- Data de calculo do Price
      vr_dtmvtolt := pr_dtcalcul;

      -- Funcao para retornar o dia anterior
      vr_dtmvtoan := GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                 pr_dtmvtolt  => vr_dtmvtolt - 1,
                                                 pr_tipo      => 'A');

      -- Funcao para retornar o proximo dia
      vr_dtmvtopr := GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                 pr_dtmvtolt  => vr_dtmvtolt + 1,
                                                 pr_tipo      => 'P');

      -- Buscar os dados de emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
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
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      vr_blnachou := cr_craplcr%FOUND;
      CLOSE cr_craplcr;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_cdcritic := 363;
        RAISE vr_exc_erro;
      END IF;

      -- Se for a Mensal
      vr_flmensal := (TO_CHAR(vr_dtmvtolt, 'MM') <> TO_CHAR(vr_dtmvtopr, 'MM'));

      -- Se for Financiamento
      vr_floperac := (rw_craplcr.dsoperac = 'FINANCIAMENTO');

      -- Seta o nome da origem
      vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);

      -- Calcula a taxa diaria
      vr_txdiaria := POWER(1 + (NVL(rw_crapepr.txmensal,0) / 100),(1 / 30)) - 1;

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

      -- Buscar os dados da parcela
      OPEN cr_crappep(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrparepr => pr_nrparepr);
      FETCH cr_crappep INTO rw_crappep;
      vr_blnachou := cr_crappep%FOUND;
      CLOSE cr_crappep;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_dscritic := 'Parcela ' || TO_CHAR(pr_nrparepr) || ' nao encontrada.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Verificar se a parcela jah esta liquidada
      IF rw_crappep.inliquid = 1 THEN
        vr_dscritic := 'Parcela ' || TO_CHAR(pr_nrparepr) || ' ja liquidada!';
        RAISE vr_exc_erro;
      END IF;

      -- Verifica se tem alguma parcela anterior em aberto
      OPEN cr_pep_ant(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nrparepr => pr_nrparepr
                     ,pr_dtvencto => pr_dtcalcul);
      FETCH cr_pep_ant INTO rw_pep_ant;
      vr_blnachou := cr_pep_ant%FOUND;
      CLOSE cr_pep_ant;
      -- Se achou
      IF vr_blnachou THEN
        vr_dscritic := 'Efetuar primeiro o pagamento da parcela em atraso';
        RAISE vr_exc_erro;
      END IF;
      
      -- Cursor para buscar se o pagamento está na ordem correta
			OPEN cr_crappep_ordem1(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctremp => pr_nrctremp
                            ,pr_nrparepr => pr_nrparepr);
      FETCH cr_crappep_ordem1 INTO rw_crappep_ordem1;
      vr_blnachou_ordem1 := cr_crappep_ordem1%FOUND;
      CLOSE cr_crappep_ordem1;
      
      -- Cursor para buscar se o pagamento está na ordem correta
      OPEN cr_crappep_ordem2(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctremp => pr_nrctremp
                            ,pr_nrparepr => pr_nrparepr);
      FETCH cr_crappep_ordem2 INTO rw_crappep_ordem2;
      vr_blnachou_ordem2 := cr_crappep_ordem2%FOUND;
      CLOSE cr_crappep_ordem2;
      
 			IF vr_blnachou_ordem1 AND vr_blnachou_ordem2 THEN
				vr_dscritic := 'Efetuar o pagamento das parcelas na sequencia crescente ou decrescente';
				RAISE vr_exc_erro;
      END IF;
           
      --------------------
      -- Parcela em dia --
      --------------------
      IF rw_crappep.dtvencto > vr_dtmvtoan AND rw_crappep.dtvencto <= vr_dtmvtolt THEN
        -- Efetua o pagamento da parcela em Dia
        pc_efetua_pagamento_em_dia(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => pr_cdprogra
                                  ,pr_dtmvtoan => vr_dtmvtoan
                                  ,pr_dtmvtolt => vr_dtmvtolt
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdpactra => pr_cdpactra
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_cdorigem => pr_idorigem
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_vlpreemp => rw_crapepr.vlpreemp
                                  ,pr_qtprepag => rw_crapepr.qtprepag
                                  ,pr_qtprecal => rw_crapepr.qtprecal
                                  ,pr_dtlibera => rw_crapepr.dtlibera
                                  ,pr_dtrefjur => rw_crapepr.dtrefjur
                                  ,pr_diarefju => rw_crapepr.diarefju
                                  ,pr_mesrefju => rw_crapepr.mesrefju
                                  ,pr_anorefju => rw_crapepr.anorefju
                                  ,pr_vlrdtaxa => rw_crappep.vltaxatu
                                  ,pr_txdiaria => vr_txdiaria
                                  ,pr_txjuremp => rw_crapepr.txjuremp
                                  ,pr_vlsprojt => rw_crapepr.vlsprojt
                                  ,pr_floperac => vr_floperac
                                  ,pr_nrseqava => pr_nrseqava
                                  ,pr_nrparepr => pr_nrparepr
                                  ,pr_dtvencto => rw_crappep.dtvencto
                                  ,pr_vlpagpar => pr_vlpagpar
                                  ,pr_vlsdvpar => rw_crappep.vlsdvpar
                                  ,pr_vlsdvatu => rw_crappep.vlsdvatu
                                  ,pr_vljura60 => rw_crappep.vljura60
                                  ,pr_ehmensal => vr_flmensal
                                  ,pr_dtrefcor => rw_crapepr.dtrefcor                                  
                                  ,pr_txmensal => rw_crapepr.txmensal
                                  ,pr_dtdstjur => rw_crappep.dtdstjur
                                  ,pr_vlpagpar_atu => NVL(rw_crappep.vlpagpar,0) + 
                                                      NVL(rw_crappep.vldstrem,0) + 
                                                      NVL(rw_crappep.vldstcor,0)                                 
                                  ,pr_nmdatela => pr_nmdatela
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
        pc_efetua_pagamento_em_atraso(pr_cdcooper => pr_cdcooper
                                     ,pr_cdprogra => pr_cdprogra
                                     ,pr_dtcalcul => vr_dtmvtolt
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_cdpactra => pr_cdpactra
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_cdorigem => pr_idorigem
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_vlpreemp => rw_crapepr.vlpreemp
                                     ,pr_qtprepag => rw_crapepr.qtprepag
                                     ,pr_qtprecal => rw_crapepr.qtprecal
                                     ,pr_txjuremp => rw_crapepr.txjuremp
                                     ,pr_qttolatr => rw_crapepr.qttolatr
                                     ,pr_floperac => vr_floperac
                                     ,pr_nrseqava => pr_nrseqava
                                     ,pr_cdlcremp => rw_crapepr.cdlcremp
                                     ,pr_nrparepr => pr_nrparepr
                                     ,pr_dtvencto => rw_crappep.dtvencto
                                     ,pr_dtultpag => rw_crappep.dtultpag
                                     ,pr_vlparepr => rw_crappep.vlparepr
                                     ,pr_vlpagpar => pr_vlpagpar
                                     ,pr_vlsdvpar => rw_crappep.vlsdvpar
                                     ,pr_vlsdvatu => rw_crappep.vlsdvatu
                                     ,pr_vljura60 => rw_crappep.vljura60
                                     ,pr_vlpagmta => rw_crappep.vlpagmta
                                     ,pr_perjurmo => rw_craplcr.perjurmo
                                     ,pr_percmult => vr_percmult
                                     ,pr_txmensal => rw_crapepr.txmensal
                                     ,pr_idfiniof => rw_crapepr.idfiniof
                                     ,pr_vlemprst => rw_crapepr.vlemprst
                                     ,pr_nmdatela => pr_nmdatela
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
        -- Efetua o pagamento da parcela vencer
        pc_efetua_pagamento_vencer(pr_cdcooper  => pr_cdcooper
                                  ,pr_cdprogra  => pr_cdprogra
                                  ,pr_dtmvtoan  => vr_dtmvtoan
                                  ,pr_dtmvtolt  => vr_dtmvtolt
                                  ,pr_cdagenci  => pr_cdagenci
                                  ,pr_cdpactra  => pr_cdpactra
                                  ,pr_cdoperad  => pr_cdoperad
                                  ,pr_cdorigem  => pr_idorigem
                                  ,pr_flgbatch  => pr_flgbatch
                                  ,pr_ehmensal  => vr_flmensal
                                  ,pr_nrdconta  => pr_nrdconta
                                  ,pr_nrctremp  => pr_nrctremp
                                  ,pr_dtefetiv  => rw_crapepr.dtmvtolt
                                  ,pr_txdiaria  => vr_txdiaria
                                  ,pr_txmensal  => rw_crapepr.txmensal
                                  ,pr_dtrefjur  => rw_crapepr.dtrefjur
                                  ,pr_diarefju  => rw_crapepr.diarefju
                                  ,pr_mesrefju  => rw_crapepr.mesrefju
                                  ,pr_anorefju  => rw_crapepr.anorefju
                                  ,pr_txjuremp  => rw_crapepr.txjuremp
                                  ,pr_dtdpagto  => rw_crapepr.dtdpagto
                                  ,pr_vlsprojt  => rw_crapepr.vlsprojt
                                  ,pr_nrseqava  => pr_nrseqava
                                  ,pr_floperac  => vr_floperac
                                  ,pr_nrparepr  => rw_crappep.nrparepr
                                  ,pr_dtvencto  => rw_crappep.dtvencto
                                  ,pr_vlparepr  => rw_crappep.vlparepr
                                  ,pr_vlpagpar  => pr_vlpagpar
                                  ,pr_vlsdvpar  => rw_crappep.vlsdvpar
                                  ,pr_vltaxatu  => rw_crappep.vltaxatu
                                  ,pr_dtrefcor  => rw_crapepr.dtrefcor
                                  ,pr_tab_price => pr_tab_price
																	,pr_nmdatela  => pr_nmdatela
                                  ,pr_inliqpep  => vr_inliqpep
                                  ,pr_vlsdeved  => vr_vlsdeved
                                  ,pr_cdcritic  => vr_cdcritic
                                  ,pr_dscritic  => vr_dscritic);
      
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;      
        
         
        -- Rotina para gerar os dados da antecipação para o MITRA
        pc_mitra_gera_antecipacao(pr_cdcooper  => pr_cdcooper   -- Cooperativa
                                 ,pr_nrdconta  => pr_nrdconta   -- Conta do cooperado
                                 ,pr_nrctremp  => pr_nrctremp   -- Número do contrato de empréstimo
                                 ,pr_vlsdeved  => vr_vlsdeved   -- Saldo devedor do empréstimo
                                 ,pr_vlrpagto  => pr_vlpagpar   -- Valor pago da parcela
                                 ,pr_nrpeppag  => rw_crappep.nrparepr -- Número da parcela do empréstimo
                                 ,pr_inliqpep  => vr_inliqpep   -- Indica se a parcela paga foi liquidada
                                 ,pr_dscritic  => vr_dscritic); -- Retorno de críticas
          
        -- Se houve erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF; 
        
      END IF; -- Parcela a Vencer

      -- Faz a liquidacao do contrato
      EMPR0011.pc_efetua_liquidacao_empr_pos(pr_cdcooper   => pr_cdcooper
                                            ,pr_nrdconta   => pr_nrdconta
                                            ,pr_nrctremp   => pr_nrctremp
                                            ,pr_rw_crapdat => rw_crapdat
                                            ,pr_cdagenci   => pr_cdagenci
                                            ,pr_cdpactra   => pr_cdpactra
                                            ,pr_cdoperad   => pr_cdoperad
                                            ,pr_nrdcaixa   => pr_nrdcaixa
                                            ,pr_cdorigem   => pr_idorigem
                                            ,pr_nmdatela   => pr_nmdatela
                                            ,pr_floperac   => vr_floperac
                                            ,pr_cdcritic   => vr_cdcritic
                                            ,pr_dscritic   => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Gera log do pagamento
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Pag. Emp/Fin Nr ' || GENE0002.fn_mask_contrato(pr_nrctremp) || '/' || TO_CHAR(pr_nrparepr)
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 -- TRUE
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
            
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'nrparepr',
                                pr_dsdadant => pr_nrparepr,
                                pr_dsdadatu => pr_nrparepr);
            
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'vlpagpar',
                                pr_dsdadant => TO_CHAR(pr_vlpagpar,'FM999G999G999G990D00'),
                                pr_dsdadatu => TO_CHAR(pr_vlpagpar,'FM999G999G999G990D00'));

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
        pr_dscritic := 'Erro na procedure pc_gera_pagto_pos: ' || SQLERRM;
    END;

  END pc_gera_pagto_pos;

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
      -- Variaveis Locais
      vr_dtcalcul  DATE;
      vr_parc_lst  GENE0002.typ_split;
      vr_parc_reg  GENE0002.typ_split;
      vr_nrparepr  INTEGER;
      vr_vlpagpar  NUMBER;
      vr_tab_price typ_tab_price;
    
      -- Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    
      -- Variaveis Excecao
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      vr_tab_price.DELETE;
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

      -- Data de calculo do Price
      vr_dtcalcul := TO_DATE(pr_dtcalcul,'DD/MM/RRRR');

      -- Quebra string para transformar numa tabela com os registros
      vr_parc_lst := GENE0002.fn_quebra_string(pr_string  => pr_dadosprc
                                              ,pr_delimit => '|');

      -- Listagem de pagamentos informados
      FOR vr_idx_lst IN 1..vr_parc_lst.COUNT LOOP

        -- Quebra string para transformar nos registros
        vr_parc_reg := GENE0002.fn_quebra_string(pr_string  => vr_parc_lst(vr_idx_lst)
                                                 ,pr_delimit => ';');
        -- Seta os valores separados
        vr_nrparepr := vr_parc_reg(1);
        vr_vlpagpar := TO_NUMBER(vr_parc_reg(2));

        -- Chama pagamento da parcela
        pc_gera_pagto_pos(pr_cdcooper  => vr_cdcooper
                         ,pr_cdprogra  => vr_nmdatela
                         ,pr_dtcalcul  => vr_dtcalcul
                         ,pr_nrdconta  => pr_nrdconta
                         ,pr_nrctremp  => pr_nrctremp
                         ,pr_nrparepr  => vr_nrparepr
                         ,pr_vlpagpar  => vr_vlpagpar
                         ,pr_idseqttl  => pr_idseqttl
                         ,pr_cdagenci  => vr_cdagenci
                         ,pr_cdpactra  => pr_cdpactra
                         ,pr_nrdcaixa  => vr_nrdcaixa
                         ,pr_cdoperad  => vr_cdoperad
                         ,pr_nrseqava  => pr_nrseqava
                         ,pr_idorigem  => vr_idorigem
                         ,pr_nmdatela  => vr_nmdatela
                         ,pr_tab_price => vr_tab_price
                         ,pr_cdcritic  => vr_cdcritic
                         ,pr_dscritic  => vr_dscritic);
                         
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END LOOP;

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

  PROCEDURE pc_busca_prest_principal_pos(pr_cdcooper         IN crapepr.cdcooper%TYPE     --> Codigo da Cooperativa
                                        ,pr_dtefetiv         IN crapepr.dtmvtolt%TYPE     --> Data de Efetivação do Emprestimo
                                        ,pr_dtcalcul         IN crapdat.dtmvtolt%TYPE     --> Data de calculo das parcelas
                                        ,pr_cdlcremp         IN craplcr.cdlcremp%TYPE     --> Codigo da Linha de Credito
                                        ,pr_dtcarenc         IN crawepr.dtcarenc%TYPE     --> Data de Pagamento da Primeira Carencia
                                        ,pr_dtdpagto         IN crapepr.dtdpagto%TYPE     --> Data do pagamento
                                        ,pr_qtpreemp         IN crapepr.qtpreemp%TYPE     --> Quantidade de prestacoes
                                        ,pr_vlemprst         IN crapepr.vlemprst%TYPE     --> Valor do emprestimo
                                        ,pr_qtdias_carencia  IN tbepr_posfix_param_carencia.qtddias%TYPE --> Quantidade de Dias
                                        ,pr_vlpreemp        OUT crapepr.vlpreemp%TYPE     --> Valor da prestacao
                                        ,pr_vljurcor        OUT crapepr.vlpreemp%TYPE     --> Valor do Juros de Correcao
                                        ,pr_cdcritic        OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                        ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS --> Descricao da critica
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
      vr_dtvencto            DATE;
      vr_vlpreemp            NUMBER := 0;
      vr_vljurcor            NUMBER := 0;
      vr_qtdia_uteis         PLS_INTEGER;
      vr_data_inicial        DATE;
      vr_taxa_periodo        NUMBER(25,10);
      vr_tab_parcelas        EMPR0011.typ_tab_parcelas;

      -- Variaveis tratamento de erros
      vr_cdcritic            crapcri.cdcritic%TYPE;
      vr_dscritic            crapcri.dscritic%TYPE;
      vr_exc_erro            EXCEPTION;

    BEGIN
      -- Chama o calculo da parcela
      pc_calcula_parcelas_pos_fixado(pr_cdcooper        => pr_cdcooper
                                    ,pr_dtcalcul        => pr_dtcalcul
                                    ,pr_cdlcremp        => pr_cdlcremp
                                    ,pr_dtcarenc        => pr_dtcarenc
                                    ,pr_qtdias_carencia => pr_qtdias_carencia
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
          vr_dtvencto := vr_tab_parcelas(vr_indice).dtvencto;
          
          --------------------------------------------------------------------------------------------
          -- Regras do Cálculo do Juros de Correcao na Mensal
          --------------------------------------------------------------------------------------------          
          IF TO_CHAR(pr_dtefetiv,'MM') <> TO_CHAR(vr_dtvencto,'MM') THEN
            -- Condicao para verificar a Data Inicial de Cálculo
            IF (TO_NUMBER(TO_CHAR(pr_dtefetiv,'DD')) > TO_NUMBER(TO_CHAR(vr_dtvencto,'DD'))) AND vr_tab_parcelas(vr_indice).nrparepr = 1 THEN
              vr_data_inicial := pr_dtefetiv;
            ELSE
              vr_data_inicial := ADD_MONTHS(vr_dtvencto,-1);
            END IF;
            
            -- Calcula a diferenca entre duas datas e retorna os dias Uteis
            pc_calcula_qtd_dias_uteis(pr_cdcooper    => pr_cdcooper
                                     ,pr_flgbatch    => FALSE
                                     ,pr_dtefetiv    => pr_dtefetiv
                                     ,pr_datainicial => vr_data_inicial
                                     ,pr_datafinal   => LAST_DAY(vr_data_inicial)
                                     ,pr_qtdiaute    => vr_qtdia_uteis
                                     ,pr_cdcritic    => vr_cdcritic
                                     ,pr_dscritic    => vr_dscritic);
            
            -- Condicao para verificar se houve erro
            IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Cálculo da Taxa do Periodo
            vr_taxa_periodo := POWER((1 + (vr_tab_parcelas(vr_indice).vlrdtaxa / 100)),(vr_qtdia_uteis / 252)) - 1;
            -- Cálculo do Juros de Correcao
            vr_vljurcor     := vr_taxa_periodo * pr_vlemprst;
          END IF;           

          --------------------------------------------------------------------------------------------
          -- Regras do Cálculo do Juros de Correcao no vencimento da Parcela
          --------------------------------------------------------------------------------------------          
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
	--
	PROCEDURE pc_retorna_val_parc_pos_fixado(pr_cdcooper        IN  crapcop.cdcooper%TYPE                    -- Codigo da Cooperativa
                                          ,pr_dtcalcul        IN  crapdat.dtmvtolt%TYPE                    -- Data de Calculo
                                          ,pr_cdlcremp        IN  craplcr.cdlcremp%TYPE                    -- Codigo da Linha de Credito
                                          ,pr_dtcarenc        IN  crawepr.dtcarenc%TYPE                    -- Data da Carencia do Contrato
                                          ,pr_qtdias_carencia IN  tbepr_posfix_param_carencia.qtddias%TYPE -- Quantidade de Dias de Carencia
                                          ,pr_dtdpagto        IN  crapepr.dtdpagto%TYPE                    -- Data de Pagamento
                                          ,pr_qtpreemp        IN  crapepr.qtpreemp%type                    -- Quantidade de Prestacoes
                                          ,pr_vlemprst        IN  crapepr.vlemprst%TYPE                    -- Valor do Emprestimo
                                          ,pr_vlprecar        OUT crapepr.vlemprst%TYPE                    -- Valor da prestacao carencia
																					,pr_vlpreemp        OUT crapepr.vlemprst%TYPE                    -- Valor da prestacao emprestimo
                                          ,pr_cdcritic        OUT crapcri.cdcritic%TYPE                    -- Codigo da critica
                                          ,pr_dscritic        OUT crapcri.dscritic%TYPE                    -- Descricao da critica
																					) IS
		/* .............................................................................

       Programa: pc_retorna_val_parc_pos_fixado
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Adriano Nagasava (Supero)
       Data    : Dezembro/2018                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para retornar os valores parcela na carencia e parcela estimada.
    
       Alteracoes: 
			 
    ............................................................................. */
		--
		vr_exc_erro     EXCEPTION;
		vr_tab_parcelas typ_tab_parcelas;
		--
	BEGIN
		--
		pr_vlprecar := 0;
		pr_vlpreemp := 0;
    /*pr_vlemprst deve considerar o valor do IOF, ou seja, quando chamar a rotina caso tenha IOF
    considar o valor na passagem de parametro */
		--
		empr0011.pc_calcula_parcelas_pos_fixado(pr_cdcooper        => pr_cdcooper
		                                       ,pr_dtcalcul        => pr_dtcalcul
																					 ,pr_cdlcremp        => pr_cdlcremp
																					 ,pr_dtcarenc        => pr_dtcarenc
																					 ,pr_qtdias_carencia => pr_qtdias_carencia
																					 ,pr_dtdpagto        => pr_dtdpagto
																					 ,pr_qtpreemp        => pr_qtpreemp
																					 ,pr_vlemprst        => pr_vlemprst
																					 ,pr_tab_parcelas    => vr_tab_parcelas
																					 ,pr_cdcritic        => pr_cdcritic
																					 ,pr_dscritic        => pr_dscritic
																					 );
		--
		IF pr_cdcritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
			--
			RAISE vr_exc_erro;
			--
		END IF;
		-- Buscar a primeira parcela com carencia e a primeira parcela sem carencia
		FOR vr_indice IN 1..vr_tab_parcelas.count() LOOP
			--
			IF vr_tab_parcelas(vr_indice).flcarenc = 1 AND 
				 nvl(pr_vlprecar, 0) = 0 THEN
				--
				pr_vlprecar := round(vr_tab_parcelas(vr_indice).vlparepr,2);
				--
			END IF;
			--
			IF vr_tab_parcelas(vr_indice).flcarenc = 0 AND 
				 nvl(pr_vlpreemp, 0) = 0 THEN
				--
				pr_vlpreemp := round(vr_tab_parcelas(vr_indice).vlparepr,2);
				EXIT;
				--
			END IF;
			--
		END LOOP;
		--
	EXCEPTION
		WHEN vr_exc_erro THEN
			NULL;
	END pc_retorna_val_parc_pos_fixado;
	--
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
                   2365,2363,2349,2348 -- Multa
                  ,2367,2369           -- Multa Aval
                  ,2371,2373,2347,2346 -- Juros de Mora
                  ,2375,2377           -- Juros de Mora Aval
                  ,2566,2567           -- Desconto
                  ,2540,2539,2607,2608); -- IOF

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
            vr_cdhistor := 2359;
          ELSE
            vr_cdhistor := 2472;
          END IF;
          
          -- Inverter sinal para efetuar o lancamento
          vr_vlresidu := vr_vlresidu * -1;
          
          vr_flgcredi := TRUE; -- Credita
          
        -- Se possui residuo positivo
        ELSIF NVL(vr_vlresidu,0) > 0 THEN
          
          -- Financiamento
          IF pr_floperac THEN
            vr_cdhistor := 2358;  
          ELSE
            vr_cdhistor := 2471;    
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
                ,crapepr.vlsprojt = 0
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
