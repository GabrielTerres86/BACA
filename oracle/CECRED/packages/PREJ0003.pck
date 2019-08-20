CREATE OR REPLACE PACKAGE CECRED.PREJ0003 AS
/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao: 18/12/2018

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Move  C.C. para prejuízo

   Alteracoes: 27/06/2018 - P450 - Criação de procedure para consulta de saldos - pc_consulta_sld_cta_prj (Daniel/AMcom)
               27/06/2018 - P450 - Criação de procedure para efetuar lançamentos - pc_gera_lcm_cta_prj (Daniel/AMcom)
               28/06/2018 - P450 - Criação de procedure para liquidar conta em prejuizo - pc_liquida_prejuizo_cc (Rangel/Amcom)
               13/07/2018 - P450 - Criação rotina para calcular juros de prejuizos - pc_calc_juro_remuneratorio
               18/07/2018  -P450 - Pagamento Prejuizo de Forma Automática  - pc_paga_prejuizo_cc   (Rangel Decker/AMcom)
               06/08/2018 - 9318:Pagamento de Emprestimo   -pc_pagar_contrato_emprestimo   Rangel Decker (AMcom)
               28/08/2018 - Criação de rotina para trazer o registro para estorno de prejuízo de conta corrente
                            PJ 450 - Diego Simas (AMcom)
               25/09/2018 - Validar campo justificativa do estorno da Conta Transitória
                            PJ 450 - Diego Simas (AMcom)
               06/11/2018 - P450 - Nova procedure consultar Prejuizo Ativo (Guilherme/AMcom)
               07/11/2018 - P450 - Liquida prejuizo da conta somente se não tiver contrato de empréstimo 
                            ou de desconto de título em prejuízo (Fabio - AMcom). 
               18/12/2018 - Correção na pc_debita_juros60_prj para zerar os campos de juros+60 na CRAPSLD.
                            P450 - Reginaldo/AMcom


..............................................................................*/

  TYPE typ_reg_prejuizo IS
    RECORD(nrdconta  NUMBER
          ,nrcpfcnpj NUMBER);
  TYPE typ_tab_prejuizo IS
    TABLE OF typ_reg_prejuizo
      INDEX BY VARCHAR2(12);     -- Indexado por CPF/CNPJ Base (11) + inpessoa (1)
  vr_tab_prejuizo  typ_tab_prejuizo;


  -- Verifica se a conta corrente se encontra em prejuízo
  FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                 , pr_nrdconta craplcm.nrdconta%TYPE) RETURN BOOLEAN;
                                                                 
    -- Verifica se a conta possui algum prejuizo ativo --> CC / EMPRESTTIMO / DESC.TITULO
  FUNCTION fn_verifica_preju_ativo(pr_cdcooper craplcm.cdcooper%TYPE
                                 , pr_nrdconta craplcm.nrdconta%TYPE
                                 , pr_tipverif INTEGER DEFAULT 2) RETURN BOOLEAN;                                

                                                                 
    -- Verifica se as regras do prejuízo de conta corrente estão ativadas para a cooperativa
    FUNCTION fn_verifica_flg_ativa_prju(pr_cdcooper IN crapcop.cdcooper%TYPE) 
        RETURN BOOLEAN;

    -- Verifica se o prejuízo de conta corrente foi liquidado em uma data específica
  FUNCTION fn_verifica_liquidacao_preju(pr_cdcooper craplcm.cdcooper%TYPE
                                      , pr_nrdconta craplcm.nrdconta%TYPE
                                                                            , pr_dtmvtolt tbcc_prejuizo.dtliquidacao%TYPE) RETURN BOOLEAN;

  -- Calcula a quantidade de dias em atraso para contas corrente transferidas para prejuízo
    FUNCTION fn_calc_dias_atraso_cc_prej(pr_cdcooper IN tbcc_prejuizo.cdcooper%TYPE
                                         , pr_nrdconta IN tbcc_prejuizo.nrdconta%TYPE
                                                                         , pr_dtmvtolt IN tbcc_prejuizo.dtinclusao%TYPE) RETURN NUMBER;

  /* Rotina para inclusao de C.C. pra prejuizo */
  PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro);

  /* Rotina para liquidar prejuizo de Conta Corrente*/
  PROCEDURE pc_liquida_prejuizo_cc(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Coop conectada
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                   ,pr_dscritic OUT VARCHAR2
                                   ,pr_tab_erro OUT gene0001.typ_tab_erro  );
                                                                     
  -- Obtem o saldo devedor atual do prejuízo de conta corrente
    FUNCTION fn_obtem_saldo_prejuizo_cc(pr_cdcooper IN NUMBER
                                        , pr_nrdconta IN NUMBER)
    RETURN NUMBER;                                                                   

  FUNCTION fn_sld_cta_prj(pr_cdcooper   IN NUMBER --> Código da Cooperativa
                         ,pr_nrdconta   IN NUMBER --> Número da conta
                         ,pr_exclbloq   IN NUMBER DEFAULT 1) --> Flag que indica se devem ser excluídos (subtraídos) do saldo os créditos bloqueados (cheques ainda não compensados)
    RETURN NUMBER;

  -- Retorna a soma dos valores pagos (abonados) do prejuízo de c/c no dia
  FUNCTION fn_valor_pago_conta_prej(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE
                                  , pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE
                                  , pr_dtmvtolt IN tbcc_prejuizo_detalhe.dtmvtolt%TYPE) RETURN NUMBER;

    -- Retorna o valor de juros remuneratórios provisionados para a conta em prejuízo
    FUNCTION fn_juros_remun_prov(pr_cdcooper IN crapris.cdcooper%TYPE
                             , pr_nrdconta IN crapris.nrdconta%TYPE) RETURN NUMBER;

    -- Gera número de documento para lançar um determinado histórico na CRAPLCM sem duplicidade                      
  FUNCTION fn_gera_nrdocmto_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE
                                      , pr_nrdconta IN craplcm.nrdconta%TYPE
                                                                    , pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                                                                    , pr_cdhistor IN craplcm.cdhistor%TYPE) RETURN craplcm.nrdocmto%TYPE;                                                    

  -- Function para retornar o valor do prejuízo da conta corrente conforme a data para o Informe de Rendimentos                                   
   FUNCTION fn_obtem_saldo_hist_preju_cc(pr_cdcooper   IN NUMBER --> Código da Cooperativa
                                        ,pr_nrdconta   IN NUMBER --> Número da conta
                                        ,pr_dtmvtolt   IN DATE) RETURN NUMBER; --> Data a ser verificada para saber se aonta estava em prejuízo no período



   PROCEDURE pc_consulta_sld_cta_prj(pr_cdcooper IN NUMBER             --> Código da Cooperativa
                                   ,pr_nrdconta IN NUMBER             --> Número da conta
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

    -- Retornar o valor do prejuízo da conta corrente conforme a data para o Informe de Rendimentos
    PROCEDURE pc_obtem_saldo_hist_preju_cc(pr_cdcooper   IN NUMBER --> Código da Cooperativa
                                          ,pr_nrdconta   IN NUMBER --> Número da conta
                                          ,pr_dtmvtolt   IN DATE   --> Data a ser verificada para saber se aonta estava em prejuízo no período
                                          ,pr_vlblqprj  OUT NUMBER ); --> Retorna valor bloqueado prejuizo na data

    PROCEDURE pc_gera_lcm_cta_prj(pr_cdcooper  IN NUMBER             --> Código da Cooperativa
                                 ,pr_nrdconta  IN NUMBER             --> Número da conta
                                 ,pr_cdoperad  IN VARCHAR2           --> Código do Operador
                                 ,pr_vlrlanc   IN NUMBER             --> Valor do Lançamento
                                 ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);        --> Erros do processo

   PROCEDURE pc_gera_transf_cta_prj(pr_cdcooper IN NUMBER
                                , pr_nrdconta IN NUMBER
                                , pr_cdoperad IN VARCHAR2 DEFAULT '1'
                                , pr_vllanmto IN NUMBER
                                , pr_dtmvtolt IN DATE
                                , pr_versaldo IN INTEGER DEFAULT 1 -- Se deve validar o saldo disponível
                                , pr_atsldlib IN INTEGER DEFAULT 1 -- Se deve atualizar o saldo disponível para operações na conta corrente (VLSLDLIB)
                                , pr_dsoperac IN VARCHAR2 DEFAULT NULL -- Descrição da operação que originou a transferência
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE);
                                                                
   PROCEDURE pc_gera_cred_cta_prj(pr_cdcooper  IN NUMBER                 --> Código da Cooperativa
                                 ,pr_nrdconta  IN NUMBER                --> Número da conta
                                 ,pr_cdoperad  IN VARCHAR2 DEFAULT '1'  --> Código do Operador
                                 ,pr_vlrlanc   IN NUMBER                --> Valor do Lançamento
                                 ,pr_dtmvtolt  IN DATE                  --> Data da cooperativa
                                 ,pr_nrdocmto  IN tbcc_prejuizo_lancamento.nrdocmto%TYPE DEFAULT NULL
                                 ,pr_dsoperac  IN VARCHAR2 DEFAULT NULL --> Descrição da operação que originou o crédito (Ex. Desbloqueio de acordo, Liberação de crédito de empréstimo, etc)
                                 ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2);                                                           

   PROCEDURE pc_gera_debt_cta_prj(pr_cdcooper  IN NUMBER                 --> Código da Cooperativa
                                 ,pr_nrdconta  IN NUMBER                --> Número da conta
                                 ,pr_cdoperad  IN VARCHAR2 DEFAULT '1'  --> Código do Operador
                                 ,pr_vlrlanc   IN NUMBER                --> Valor do Lançamento
                                 ,pr_dtmvtolt  IN DATE                  --> Data da cooperativa
                                 ,pr_dsoperac  IN VARCHAR2 DEFAULT NULL --> Descrição breve da operação que originou o débito (Ex. Pagamento de empréstimo, bloqueio de acordo, etc)
                                 ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2);        --> Erros do processo


  PROCEDURE pc_grava_prejuizo_cc(pr_cdcooper       IN crapcop.cdcooper%TYPE   --> Coop conectada
                                ,pr_nrdconta      IN  crapass.nrdconta%TYPE  --> NR da Conta
                                ,pr_tpope         IN VARCHAR2 DEFAULT 'N'    --> Tipo de Operação(N-Normal F-Fraude)
                                ,pr_cdcritic      OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                ,pr_dscritic      OUT VARCHAR2               --> Descrição da Critica
                                ,pr_des_erro      OUT VARCHAR2);


  PROCEDURE pc_cancela_servicos_cc_prj(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Coop conectada
                                     ,pr_nrdconta       IN crapass.nrdconta%TYPE --> NR da Conta
                                     ,pr_dtinc_prejuizo IN crapris.dtinictr%TYPE --> Data que entrou em prejuizo
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2 );

   PROCEDURE pc_erro_transfere_prejuizo(pr_cdcooper       IN crapcop.cdcooper%TYPE  --> Coop conectada
                                      ,pr_dtmvtolt       IN crapdat.dtmvtolt%TYPE  --> Data do movimento atual
                                      ,pr_clobarq        IN OUT NOCOPY CLOB                                            --> clob para conter o dados do excel/csv
                                      ,pr_cdcritic       OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic       OUT VARCHAR2              -->Descrição Critica
                                      ,pr_tab_erro       OUT gene0001.typ_tab_erro);

PROCEDURE pc_ret_saldo_dia_prej ( pr_cdcooper  IN crapcop.cdcooper%TYPE         --> Coop conectada
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE         --> Numero da conta
                                 ,pr_dtmvtolt  IN DATE                          --> Data incio do periodo do prejuizo
                                 ,pr_exclbloq  IN NUMBER DEFAULT 0              --> Se deve subtrair os créditos bloqueados
                                 ,pr_vldsaldo OUT NUMBER                        --> Retorna valor do saldo
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE         --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2 );

  PROCEDURE pc_transf_cc_preju_fraude(pr_cdcooper   IN NUMBER             --> Cooperativa conectada
                                     ,pr_nrdconta   IN NUMBER             --> Número da conta
                                     ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2          --> Descrição da crítica
                                     ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2);        --> Erros do processo

  PROCEDURE pc_calc_juro_prejuizo_mensal (pr_cdcooper IN NUMBER
                                        , pr_cdcritic    OUT crapcri.cdcritic%TYPE
                                        , pr_dscritic    OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_calc_juro_remuneratorio (pr_cdcooper    IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                  ,pr_ehmensal    IN BOOLEAN --Indicador Mensal
                                  ,pr_dtdpagto    IN crapdat.dtmvtolt%TYPE --Data pagamento
                                  ,pr_idprejuizo  IN NUMBER -- indicador do prejuizo a ser calculado
                                  ,pr_vljpreju    OUT NUMBER --Valor Juros no Mes
                                  ,pr_diarefju    OUT INTEGER --Dia Referencia Juros
                                  ,pr_mesrefju    OUT INTEGER --Mes Referencia Juros
                                  ,pr_anorefju    OUT INTEGER --Ano Referencia Juros
                                  ,pr_des_reto    OUT VARCHAR2 --Retorno OK/NOK
                                  );

 PROCEDURE pc_calc_juros_remun_prov(pr_cdcooper IN tbcc_prejuizo.cdcooper%TYPE
                                  , pr_nrdconta IN tbcc_prejuizo.nrdconta%TYPE
                                  , pr_vljuprov OUT tbcc_prejuizo.vljuprej%TYPE
                                  , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  , pr_dscritic OUT crapcri.dscritic%TYPE);

 PROCEDURE pc_pagar_prejuizo_cc(pr_cdcooper IN crapass.cdcooper%TYPE
                              , pr_nrdconta IN crapass.nrdconta%TYPE
                              , pr_vlrpagto IN craplcm.vllanmto%TYPE
                              , pr_vlrabono IN craplcm.vllanmto%TYPE DEFAULT NULL
                                                            , pr_atsldlib IN INTEGER DEFAULT 1 -- se deve atualizar o saldo liberado para operações na conta corrente
                              , pr_cdcritic OUT crapcri.cdcritic%TYPE
                              , pr_dscritic OUT crapcri.dscritic%TYPE);

PROCEDURE pc_pagar_prejuizo_cc_autom(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro);

PROCEDURE pc_resgata_cred_bloq_preju(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2);

 /* Realizar pagamento do IOF de conta em prejuizo*/
 PROCEDURE pc_pagar_IOF_conta_prej(pr_cdcooper  IN craplcm.cdcooper%TYPE        -- Código da Cooperativa
                                 ,pr_nrdconta  IN craplcm.nrdconta%TYPE        -- Número da Conta
                                 ,pr_vllanmto  IN craplcm.vllanmto%TYPE        -- Valor do Lançamento
                                 ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE
                                 ,pr_vlbasiof  IN crapsld.vlbasiof%TYPE
                                 ,pr_idlautom  IN craplcm.idlautom%TYPE DEFAULT 0
                                 ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                 ,pr_dscritic OUT VARCHAR2);

  -- Debita os valores provisionados para os históricos de juros +60 (37, 38 e 57)
  PROCEDURE pc_debita_juros60_prj(pr_cdcooper IN crapsld.cdcooper%TYPE   --> Coop conectada
                                 ,pr_nrdconta IN crapsld.nrdconta%TYPE   --> Número da conta
                                 ,pr_vlhist37 OUT NUMBER                 --> Valor debitador para o histórico 37
                                 ,pr_vlhist57 OUT NUMBER                 --> Valor debitador para o histórico 57
                                 ,pr_vlhist38 OUT NUMBER                 --> Valor debitador para o histórico 38
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_lanca_transf_extrato_prj(pr_cdcooper          IN tbcc_prejuizo.cdcooper%TYPE
                                       , pr_nrdconta          IN tbcc_prejuizo.nrdconta%TYPE
                                      , pr_idprejuizo        IN tbcc_prejuizo.idprejuizo%TYPE
                                      , pr_vlsldprj          IN tbcc_prejuizo.vlsdprej%TYPE
                                      , pr_vljur60_ctneg     IN tbcc_prejuizo.vljur60_ctneg%TYPE
                                      , pr_vljur60_lcred     IN tbcc_prejuizo.vljur60_lcred%TYPE
                                      , pr_dtmvtolt          IN crapdat.dtmvtolt%TYPE
                                      , pr_tpope             IN VARCHAR
                                      , pr_cdcritic          OUT crapcri.cdcritic%TYPE
                                      , pr_dscritic          OUT crapcri.dscritic%TYPE);


  PROCEDURE pc_pagar_contrato_emprestimo(pr_cdcooper  IN crapepr.cdcooper%TYPE       -- Código da Cooperativa
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE       -- Número da Conta
                                        ,pr_cdagenci  IN NUMBER                      -- Código da agencia
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE       -- Número do contrato de empréstimo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                        ,pr_cdoperad  IN VARCHAR2                    -- Código do operador
                                        ,pr_vlrpagto  IN NUMBER                      -- Valor pago
                                        ,pr_vlrabono  IN NUMBER DEFAULT 0            -- Valor do abono concedido (aplicado somente a contratos em prejuízo)
                                        ,pr_idorigem  IN NUMBER                      -- Indicador da origem
                                        ,pr_idvlrmin OUT NUMBER                      -- Indica que houve critica do valor minimo
                                        ,pr_vltotpag OUT NUMBER                      -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                      -- Código de críticia
                                        ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_atualiza_sld_lib_prj(pr_cdcooper IN tbcc_prejuizo.cdcooper%TYPE
                                  , pr_nrdconta IN tbcc_prejuizo.nrdconta%TYPE
                                  , pr_vlrdebto IN tbcc_prejuizo.vlsldlib%TYPE
                                  , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  , pr_dscritic OUT crapcri.dscritic%TYPE
                                  , pr_des_erro OUT VARCHAR);

  PROCEDURE pc_gera_lcto_extrato_prj(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE
                                   , pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE
                                   , pr_dtmvtolt IN tbcc_prejuizo_detalhe.dtmvtolt%TYPE
                                   , pr_cdhistor IN tbcc_prejuizo_detalhe.cdhistor%TYPE
                                   , pr_idprejuizo IN tbcc_prejuizo_detalhe.idprejuizo%TYPE DEFAULT NULL
                                   , pr_vllanmto IN tbcc_prejuizo_detalhe.vllanmto%TYPE
                                   , pr_nrctremp IN tbcc_prejuizo_detalhe.nrctremp%TYPE DEFAULT 0
                                   , pr_cdoperad IN tbcc_prejuizo_detalhe.cdoperad%TYPE DEFAULT '1'
                                   , pr_dthrtran IN tbcc_prejuizo_detalhe.dthrtran%TYPE DEFAULT NULL
                                   , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   , pr_dscritic OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_sld_cta_prj(pr_cdcooper IN NUMBER
                         , pr_nrdconta IN NUMBER
                         , pr_vlrsaldo OUT NUMBER
                         , pr_cdcritic OUT crapcri.cdcritic%TYPE
                         , pr_dscritic OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_busca_sit_bloq_preju(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

  PROCEDURE pc_cred_disp_prj(pr_cdcooper IN NUMBER
                           , pr_nrdconta IN NUMBER
                           , pr_vlrsaldo OUT NUMBER
                           , pr_cdcritic OUT crapcri.cdcritic%TYPE
                           , pr_dscritic OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_busca_pagto_estorno_prj(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                      ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                      --> CAMPOS IN/OUT PADRÃO DA MENSAGERIA
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

  PROCEDURE pc_grava_estorno_preju(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE --> Conta do cooperado
                                  ,pr_totalest IN tbcc_prejuizo_detalhe.vllanmto%TYPE --> Total a estornar
                                  ,pr_justific IN VARCHAR2                            --> Descrição da justificativa
                                  --> CAMPOS IN/OUT PADRÃO DA MENSAGERIA
                                  ,pr_xmllog   IN VARCHAR2                            --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER                        --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2                           --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType                  --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2                           --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);                         --> Saida OK/NOK

  PROCEDURE pc_consulta_estorno_preju(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE --> Código da cooperativa
                                     ,pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE --> Conta do cooperado
                                     --> CAMPOS IN/OUT PADRÃO DA MENSAGERIA
                                     ,pr_xmllog   IN VARCHAR2                            --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                        --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                           --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType                  --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                           --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);                         --> Saida OK/NOK

  PROCEDURE pc_define_situacao_cc_prej(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE   --> Código da cooperativa
                                      ,pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE --> Conta do cooperado
                                      ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                                          ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                      );

  -- Procedure da Tela: ESTORN, Acao: Relatorio Estorno Pagamento de Prejuizo C/C
  PROCEDURE pc_tela_imprimir_relatorio(pr_nrdconta IN crapepr.nrdconta%TYPE        --> Numero da Conta
                                      ,pr_dtmvtolt IN VARCHAR2                     --> Data de Movimento
                                      ,pr_dtiniest IN VARCHAR2                     --> Data Inicio do Estorno
                                      ,pr_dtfinest IN VARCHAR2                     --> Data Fim do Estorno
                                      --> CAMPOS IN/OUT PADRÃO DA MENSAGERIA
                                      ,pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);                  --> Erros do processo

                                                                      
end PREJ0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0003 AS
/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   :Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao: 24/04/2019

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Transferencia do prejuizo de conta corrente

   Alteracoes: 27/06/2018 - P450 - Criação de procedure para consulta de saldos - pc_consulta_sld_cta_prj (Daniel/AMcom)
               27/06/2018 - P450 - Criação de procedure para efetuar lançamentos - pc_gera_lcm_cta_prj (Daniel/AMcom)
               28/06/2018 - P450 - Contingência para contas não transferidas para prejuízo - Diego Simas - AMcom
               18/07/2018  -P450 - Pagamento Prejuizo de Forma Automática  - pc_paga_prejuizo_cc
                             30/10/2018 - P450 - Ajuste no pagamento do prejuízo para fixar o DTHRTRAN que é gravado na 
                                          TBCCC_PREJUIZO_DETALHE - Reginaldo - AMcom
               07/11/2018 - P450 - Liquida prejuizo da conta somente se não tiver contrato de empréstimo 
                            ou de desconto de título em prejuízo (Fabio - AMcom).
               10/12/2018 - P450 - Inclusão de comentários (cabeçalhos) nas procedures e functions.
                            (Reginaldo - AMcom)
               10/12/2018 - P450 - Ajuste na rotina de contingência da transferência de prejuízo para ler o parâmetro
                            correto do endereço de e-mail a utilizar para envio.
                            (Reginaldo - AMcom)
               13/12/2018 - Criação da Function PREJ0003.fn_obtem_saldo_hist_preju_cc para buscar o saldo do prejuízo para 
                            mostrar no informe de rendimentos.
                            (Heckmann/AMcom/P450)
               01/02/2019 - P450 - Product Backlog Item 13920:Bugs 2019/2 - Bug 14433:Liquidação prejuízo emprestimo
                             Obs.: não estava relacionado a estória 12556, foi uma alteração feita em momento anterior, 
                             que foi a inclusão do EXISTS no cursor da crapss relacionado a tbcc_prejuizo, e neste
                             momento este foi retirado (Fabio Adriano - AMcom).                                                                         
                             
               08/02/2019 - P450 - Inclusão na "pc_pagar_prejuizo_cc_autom" de tratamento específico para o histórico 1017 se a cooperativa for Transpocred.
                            Se houver lançamentos do histórico 1017 cuja soma coincida com o valor liberado da conta 
                            transitória, não efetua o pagamento e deixa o crédito na conta corrente.
                            (Reginaldo/AMcom)
                    
               11/02/2019 - Ajuste na "pc_pagar_prejuizo_cc_autom" para correção de pagamento de valor maior que o saldo devedor do prejuízo.
                            P450 - Reginaldo/AMcom 
                            
               24/04/2019 - Refatoração da procedure pc_pagar_prejuizo_cc e inclusão de SAVEPOINT para garantir que paga tudo, ou não paga nada.
                            Alteração na procedure pc_pagar_prejuizo_cc_autom para obtem saldo disponível (créditos) da conta e não considerar mais
                            o campo VLSLDLIB.
                            P450 - Reginaldo/AMcom
                            
               02/05/2019 - Inclusão do parâmetro opcional para a descrição da operação nas procedures "pc_gera_cred_cta_prj",
                            "pc_gera_debt_cta_prj" e "pc_gera_transf_cta_prj".
                            (Reginaldo/AMcom)  
                            
..............................................................................*/

  -- clob para conter o dados do excel/csv
   vr_clobarq   CLOB;
   vr_texto_completo  VARCHAR2(32600);
   vr_mailprej  VARCHAR2(1000);

   -- Código do programa
   vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'PREJU';
   vr_exc_saida exception;

   vr_cdcritic  NUMBER(3);
   vr_dscritic  VARCHAR2(1000);


  -- Verifica se a conta está em prejuízo
  FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                  , pr_nrdconta craplcm.nrdconta%TYPE)
    RETURN BOOLEAN AS vr_conta_em_prejuizo BOOLEAN;
  /* .............................................................................

   Programa: fn_verifica_preju_conta
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Agosto/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Verifica se a conta encontra-se transferida para prejuízo

   Observacao: -----
   Alteracoes:
   ..............................................................................*/

    CURSOR cr_conta IS
    SELECT ass.inprejuz
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;

    vr_inprejuz  crapass.inprejuz%TYPE;
  BEGIN
    OPEN cr_conta;
    FETCH cr_conta INTO vr_inprejuz;
    CLOSE cr_conta;

    vr_conta_em_prejuizo := vr_inprejuz = 1;

    RETURN vr_conta_em_prejuizo;
  END fn_verifica_preju_conta;
    
  FUNCTION fn_verifica_preju_ativo(pr_cdcooper craplcm.cdcooper%TYPE
                                 , pr_nrdconta craplcm.nrdconta%TYPE
                                 , pr_tipverif INTEGER DEFAULT 2)
    RETURN BOOLEAN AS vr_prejuizo_ativo BOOLEAN;
    /* .............................................................................

   Programa: fn_verifica_preju_conta
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Guilherme Boettcher (AMcom)
   Data    : Novembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Verifica se há algum prejuízo ativo (conta, empréstimo ou desconto de título) para
                 um CPF/CNPJ base ou para uma conta específica.

   Observacao: pr_tipverif => 1-Verificação por CPF/CNPJ Base (Todas as contas de um CPF/CNPJ base)
                           => 2-Verificação apenas da Conta

   Alteracoes:
   ..............................................................................*/

    -- CURSORES
    -- Listar as contas de um CPF/CNPJ Base
    CURSOR cr_ass_cpfcnpj (pr_tipverif IN INTEGER) IS
      SELECT ass.nrdconta, ass.inprejuz
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND pr_tipverif  = 1   
         AND ass.nrcpfcnpj_base = (SELECT a.nrcpfcnpj_base
                                        FROM crapass a
                                       WHERE a.cdcooper = pr_cdcooper
                                         AND a.nrdconta = pr_nrdconta)
      UNION
      SELECT ass.nrdconta, ass.inprejuz
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND pr_tipverif  = 2
         AND ass.nrdconta = pr_nrdconta;
    rw_ass_cpfcnpj cr_ass_cpfcnpj%ROWTYPE;
    -- Verificar prejuizo de Emprestimo/CC linha 100
    CURSOR cr_preju_empr (pr_nrdconta IN crapass.nrdconta%TYPE)IS
      SELECT 1
        FROM crapepr e
       WHERE e.cdcooper = pr_cdcooper
         AND e.nrdconta = pr_nrdconta
         AND e.inprejuz = 1     -- Em prejuizo
         AND e.dtliqprj IS NULL -- Nao liquidou Prejuizo
         AND e.vlsdprej > 0;    -- Com Saldo Devedor Prejuizo
    rw_preju_empr cr_preju_empr%ROWTYPE;

    CURSOR cr_preju_dsctit (pr_nrdconta IN crapass.nrdconta%TYPE)IS
      SELECT 1
        FROM crapbdt b
       WHERE b.cdcooper = pr_cdcooper
         AND b.nrdconta = pr_nrdconta
         AND b.inprejuz = 1       -- Em Prejuizo
         AND b.dtliqprj IS NULL;  -- Prejuizo Nao Liquidado
    rw_preju_dsctit cr_preju_dsctit%ROWTYPE;

    -- Variaveis
    vr_inprejuz        crapass.inprejuz%TYPE;
    vr_tipoverificacao INTEGER;
  BEGIN
    vr_prejuizo_ativo := FALSE;
    vr_tipoverificacao := pr_tipverif;

    -- Tratar parametro invalido
    IF pr_tipverif NOT IN (1,2) THEN
      -- Assume DEFAULT => 2-Verificação apenas da Conta
      vr_tipoverificacao := 2;
    END IF;
    
    -- VERIFICAR TODAS AS CONTAS DE UM CPF/CNPJ
    FOR rw_ass_cpfcnpj IN cr_ass_cpfcnpj (vr_tipoverificacao)LOOP
    
      -- Verificar prejuizo de CC
      IF rw_ass_cpfcnpj.inprejuz = 1 THEN
         RETURN TRUE;
      END IF;
      
      -- Verificar Prejuizo de Emprestimo
      OPEN cr_preju_empr (pr_nrdconta => rw_ass_cpfcnpj.nrdconta);
      FETCH cr_preju_empr INTO vr_inprejuz;
      CLOSE cr_preju_empr;
      IF vr_inprejuz = 1 THEN
        RETURN TRUE;
      END IF;
      
      -- Verificar Prejuizo Desconto Titulo
      OPEN cr_preju_dsctit (pr_nrdconta => rw_ass_cpfcnpj.nrdconta);
      FETCH cr_preju_dsctit INTO vr_inprejuz;
      CLOSE cr_preju_dsctit;
      IF vr_inprejuz = 1 THEN
        RETURN TRUE;
      END IF;
    
    END LOOP;

    RETURN vr_prejuizo_ativo;
  END fn_verifica_preju_ativo;
    
    -- Verifica se as regras do prejuízo de conta corrente estão ativadas para a cooperativa
    FUNCTION fn_verifica_flg_ativa_prju(pr_cdcooper IN crapcop.cdcooper%TYPE) 
        RETURN BOOLEAN AS vr_flg_ativa_preju BOOLEAN;
    /* .............................................................................

   Programa: fn_verifica_flg_ativa_prju
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Novembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Verifica se as novas regras de transferência para prejuízo estão ativas para
                 uma cooperativa.

   Observacao:
   Alteracoes:
   ..............................................................................*/
    BEGIN
        vr_flg_ativa_preju := NVL(GENE0001.fn_param_sistema (pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsistem => 'CRED'
                                                        ,pr_cdacesso => 'IN_ATIVA_REGRAS_PREJU'), 'N') = 'S';
                                                                                                                
        RETURN vr_flg_ativa_preju;
    END fn_verifica_flg_ativa_prju;

    -- Verifica se o prejuízo foi liquidado em uma data específica
  FUNCTION fn_verifica_liquidacao_preju(pr_cdcooper craplcm.cdcooper%TYPE
                                      , pr_nrdconta craplcm.nrdconta%TYPE
                                                                            , pr_dtmvtolt tbcc_prejuizo.dtliquidacao%TYPE)
    RETURN BOOLEAN AS vr_liquidacao BOOLEAN;
  /* .............................................................................

   Programa: fn_verifica_liquidacao_preju
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Verifica se o prejuízo de conta corrente foi liquidado na data especificada

   Observacao:
   Alteracoes:
   ..............................................................................*/

    CURSOR cr_prejuizo IS
    SELECT 1
          FROM tbcc_prejuizo
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
             AND dtliquidacao = pr_dtmvtolt;

        vr_aux INTEGER;
  BEGIN
    OPEN cr_prejuizo;
    FETCH cr_prejuizo INTO vr_aux;

        vr_liquidacao := cr_prejuizo%FOUND;

    CLOSE cr_prejuizo;

    RETURN vr_liquidacao;
  END fn_verifica_liquidacao_preju;
    
    -- Obtem o saldo devedor atual do prejuízo de conta corrente
    FUNCTION fn_obtem_saldo_prejuizo_cc(pr_cdcooper IN NUMBER
                                        , pr_nrdconta IN NUMBER)
    RETURN NUMBER IS
      
      CURSOR cr_prejuizo IS
        SELECT prj.vlsdprej +
               prj.vljuprej +
                   prj.vljur60_ctneg +
                   prj.vljur60_lcred +
           prej0003.fn_juros_remun_prov(prj.cdcooper, prj.nrdconta) + 
           nvl(sld.vliofmes, 0) saldo
          FROM tbcc_prejuizo prj
         , crapsld sld
         WHERE prj.cdcooper = pr_cdcooper
           AND prj.nrdconta = pr_nrdconta
           AND prj.dtliquidacao IS NULL
       AND sld.cdcooper = prj.cdcooper
       AND sld.nrdconta = prj.nrdconta;
    /* .............................................................................

   Programa: fn_obtem_saldo_prejuizo_cc
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Obtém o saldo atual do prejuízo de conta corrente (saldo devedor)

   Observacao:
   Alteracoes:
   ..............................................................................*/
             
        vr_sldpreju NUMBER;
    BEGIN
        OPEN cr_prejuizo;
        FETCH cr_prejuizo INTO vr_sldpreju;
        
        IF cr_prejuizo%NOTFOUND THEN
            vr_sldpreju := 0;
        END IF;
        
        CLOSE cr_prejuizo;
        
        RETURN vr_sldpreju;
    END;                                                                

  FUNCTION fn_sld_cta_prj(pr_cdcooper   IN NUMBER --> Código da Cooperativa
                         ,pr_nrdconta   IN NUMBER --> Número da conta
                         ,pr_exclbloq   IN NUMBER DEFAULT 1) --> Flag que indica se devem ser excluídos (subtraídos) do saldo os créditos bloqueados (cheques ainda não compensados)
    RETURN NUMBER IS
  BEGIN

    /* .............................................................................

    Programa: fn_sld_conta_prejuizo
    Sistema : Ayllos
    Autor   : Daniel Silva - AMcom
    Data    : Junho/2018                 Ultima atualizacao:

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Retornar o saldo da contra transitória
    Alteracoes:
    ..............................................................................*/

    DECLARE
      -- Busca Saldo
      CURSOR cr_sld IS
        SELECT (select nvl(SUM(decode(his.indebcre, 'D', tr.vllanmto*-1, tr.vllanmto)), 0)
                  from tbcc_prejuizo_lancamento tr
                     , craphis his
                 where tr.cdcooper = pr_cdcooper
                   and tr.nrdconta = pr_nrdconta
                   and tr.dtmvtolt = (select dtmvtolt from crapdat where cdcooper = tr.cdcooper)
                   and tr.cdhistor = his.cdhistor
                   and tr.cdcooper = his.cdcooper)
                +
               (select nvl(sld.vlblqprj,0) vlsaldo
                  from crapsld sld
                 where sld.cdcooper = pr_cdcooper
                   and sld.nrdconta = pr_nrdconta) VLSALDO
           FROM DUAL;

      -- Calcula valor dos créditos bloqueados (cheques não compensados)
      CURSOR cr_credbloq IS
        SELECT nvl(SUM(tr.vllanmto), 0) vlbloqueado
          FROM tbcc_prejuizo_lancamento tr
             , craphis his
             , crapdpb blq
         WHERE tr.cdcooper = pr_cdcooper
           AND tr.nrdconta = pr_nrdconta
           AND tr.dtmvtolt >= (SELECT dtinclusao
                                 FROM tbcc_prejuizo prj
                                WHERE prj.cdcooper = pr_cdcooper
                                  AND prj.nrdconta = pr_nrdconta
                                  AND prj.dtliquidacao IS NULL)
           AND his.cdcooper = tr.cdcooper
           AND his.cdhistor = tr.cdhistor
           AND his.indebcre = 'C'
           AND blq.cdcooper = tr.cdcooper
           AND blq.nrdconta = tr.nrdconta
           AND blq.dtmvtolt = tr.dtmvtolt
           AND blq.nrdocmto = tr.nrdocmto
           AND TELA_ATENDA_DEPOSVIS.fn_soma_dias_uteis_data(pr_cdcooper, blq.dtliblan, 1) >
               (SELECT dtmvtolt FROM crapdat dat WHERE dat.cdcooper = tr.cdcooper);

      vr_sldtot      NUMBER := 0; --> Saldo total da conta transitória
      vr_crdblq      NUMBER; --> Créditos bloqueados
    BEGIN
      -- Busca saldo total da conta transitória
      OPEN cr_sld;
      FETCH cr_sld INTO vr_sldtot;
      CLOSE cr_sld;

      -- Se deve excluir (subtrair) os créditos bloqueados por cheques não compensados
      IF pr_exclbloq = 1 THEN
        OPEN cr_credbloq;
        FETCH cr_credbloq INTO vr_crdblq;
        CLOSE cr_credbloq;

        vr_sldtot := vr_sldtot - vr_crdblq;
      END IF;

      -- Retornar quantidade encontrada
      RETURN vr_sldtot;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_sld_cta_prj;

    -- Calcula a quantidade de dias em atraso para contas corrente transferidas para prejuízo
    FUNCTION fn_calc_dias_atraso_cc_prej(pr_cdcooper IN tbcc_prejuizo.cdcooper%TYPE
                                         , pr_nrdconta IN tbcc_prejuizo.nrdconta%TYPE
                                                                         , pr_dtmvtolt IN tbcc_prejuizo.dtinclusao%TYPE) RETURN NUMBER IS
    /* .............................................................................

   Programa: fn_calc_dias_atraso_cc_prej
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Calcula a quantidade de dias em atraso de uma conta transferida para prejuízo.

   Observacao:
   Alteracoes:
   ..............................................................................*/
      CURSOR cr_prejuizo IS
        SELECT qtdiaatr
             , dtinclusao
          FROM tbcc_prejuizo
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
             AND dtliquidacao IS NULL;
        rw_prejuizo cr_prejuizo%ROWTYPE;

        vr_qtdiaatr NUMBER;
    BEGIN
        OPEN cr_prejuizo;
        FETCH cr_prejuizo INTO rw_prejuizo;
        CLOSE cr_prejuizo;

        vr_qtdiaatr := nvl(rw_prejuizo.qtdiaatr, 0) + (pr_dtmvtolt - rw_prejuizo.dtinclusao);

        RETURN vr_qtdiaatr;
    END fn_calc_dias_atraso_cc_prej;

  --Retorna o valor dos créditos disponíveis na CC em prejuízo
  FUNCTION fn_cred_disp_prj(pr_cdcooper IN crapris.cdcooper%TYPE
                          , pr_nrdconta IN crapris.nrdconta%TYPE) RETURN NUMBER IS
    /* .............................................................................

   Programa: fn_cred_disp_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : retorna o valor dos créditos disponibilizados para operações na conta transitória (saque, pagamento, ...).

   Observacao:
   Alteracoes:
   ..............................................................................*/

    -- Busca valor do saldo liberado para operações na CC
    CURSOR cr_sldlib IS
    SELECT vlsldlib
      FROM tbcc_prejuizo
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND dtliquidacao IS NULL;

    vr_vlcreddisp NUMBER; -- Valor dos créditos disponíveis para uso no pagamento
  BEGIN
     OPEN cr_sldlib;
     FETCH cr_sldlib INTO vr_vlcreddisp;
     CLOSE cr_sldlib;

     RETURN vr_vlcreddisp;
  EXCEPTION
     WHEN OTHERS THEN BEGIN
       RETURN 0;
     END;
  END fn_cred_disp_prj;

  -- Retorna a soma dos valores pagos (e/ou abonados) do prejuízo de c/c em uma data
  FUNCTION fn_valor_pago_conta_prej(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE
                                  , pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE
                                  , pr_dtmvtolt IN tbcc_prejuizo_detalhe.dtmvtolt%TYPE) RETURN NUMBER IS
    /* .............................................................................

   Programa: fn_valor_pago_conta_prej
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Retorna o valor pago do prejuízo de conta corrente na data especificada.

   Observacao:
   Alteracoes:
   ..............................................................................*/

    -- Recupera somatório dos lançamentos de pagamento e abono do prejuízo de conta corrente
    CURSOR cr_pagamentos IS
    SELECT nvl(SUM(det.vllanmto), 0) valor_pagamentos
      FROM tbcc_prejuizo_detalhe det
     WHERE det.cdcooper = pr_cdcooper
       AND det.nrdconta = pr_nrdconta
       AND det.dtmvtolt = pr_dtmvtolt
       AND det.cdhistor IN (2723,2733,2323);

    vr_valor_pagamentos NUMBER;
  BEGIN
    OPEN cr_pagamentos;
    FETCH cr_pagamentos INTO vr_valor_pagamentos;
    CLOSE cr_pagamentos;

    RETURN vr_valor_pagamentos;
  END fn_valor_pago_conta_prej;

    -- Retorna o valor de juros remuneratórios provisionados para a conta em prejuízo
    FUNCTION fn_juros_remun_prov(pr_cdcooper IN crapris.cdcooper%TYPE
                             , pr_nrdconta IN crapris.nrdconta%TYPE) RETURN NUMBER IS
    /* .............................................................................

   Programa: fn_juros_remun_prov
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Retorna o valor dos juros demuneratórios de prejuízo provisionados para uma
                 conta corrente desde o último débito dos juros lançado na CRAPLCM.

   Observacao:
   Alteracoes:
   ..............................................................................*/
      vr_vljuros NUMBER;
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic crapcri.dscritic%TYPE;
    BEGIN
        pc_calc_juros_remun_prov(pr_cdcooper => pr_cdcooper
                               , pr_nrdconta => pr_nrdconta
                                                     , pr_vljuprov => vr_vljuros
                                                     , pr_cdcritic => vr_cdcritic
                                                     , pr_dscritic => vr_dscritic);

        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            vr_vljuros := 0;
        END IF;

        RETURN vr_vljuros;
    END fn_juros_remun_prov;

    -- Gera número de documento para lançar um determinado histórico na CRAPLCM sem duplicidade
    FUNCTION fn_gera_nrdocmto_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE
                                      , pr_nrdconta IN craplcm.nrdconta%TYPE
                                                                    , pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                                                                    , pr_cdhistor IN craplcm.cdhistor%TYPE) RETURN craplcm.nrdocmto%TYPE IS
    /* .............................................................................

   Programa: fn_gera_nrdocmto_craplcm
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Outubro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Gera um número de documento para uso nas inserções da CRAPLCM.

   Observacao:
   Alteracoes:
   ..............................................................................*/
                                                                    
      CURSOR cr_craplcm(pr_nrdocmto craplcm.nrdocmto%TYPE) IS
        SELECT 1
          FROM craplcm 
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
             AND dtmvtolt = pr_dtmvtolt
             AND nrdocmto = pr_nrdocmto;
            
        vr_jaexiste INTEGER;
        vr_prefixo  INTEGER := 99999;
        vr_nrdocmto craplcm.nrdocmto%TYPE;
    BEGIN
        LOOP
            vr_nrdocmto := to_number(to_char(vr_prefixo, '00000') || to_char(pr_cdhistor));
            
            OPEN cr_craplcm(vr_nrdocmto);
            FETCH cr_craplcm INTO vr_jaexiste;
            
            IF cr_craplcm%NOTFOUND THEN
                CLOSE cr_craplcm;
                EXIT;
            END IF;
            
            vr_prefixo := vr_prefixo - 1;
            CLOSE cr_craplcm;
        END LOOP;
        
        RETURN vr_nrdocmto;
    END fn_gera_nrdocmto_craplcm;

  -- Retornar o valor do prejuízo da conta corrente conforme a data para o Informe de Rendimentos
  FUNCTION fn_obtem_saldo_hist_preju_cc(pr_cdcooper   IN NUMBER --> Código da Cooperativa
                         ,pr_nrdconta   IN NUMBER --> Número da conta
                         ,pr_dtmvtolt   IN DATE) --> Data a ser verificada para saber se aonta estava em prejuízo no período
    RETURN NUMBER IS
  BEGIN

    /* .............................................................................

    Programa: fn_obtem_saldo_hist_preju_cc
    Sistema : Ayllos
    Autor   : Heckmann - AMcom
    Data    : Dezembro/2018                 Ultima atualizacao:

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Retornar o valor do prejuízo da conta corrente conforme a data para o Informe de Rendimentos
    Alteracoes:
    ..............................................................................*/

    DECLARE
      -- Busca Saldo
      CURSOR cr_sld IS
        SELECT SUM(sda.vlblqprj) vlblqprj
         FROM crapsda sda, tbcc_prejuizo prj
        WHERE sda.cdcooper = pr_cdcooper
          AND sda.nrdconta = pr_nrdconta
          AND sda.vlblqprj <> 0
          AND prj.cdcooper = sda.cdcooper
          AND prj.nrdconta = sda.nrdconta
          AND prj.dtinclusao <= pr_dtmvtolt
          AND ((prj.dtliquidacao IS NULL) OR (prj.dtliquidacao > pr_dtmvtolt))
          AND sda.dtmvtolt = gene0005.fn_valida_dia_util(pr_cdcooper, pr_dtmvtolt, 'A');

      vr_sldprj      NUMBER := 0; --> Saldo da conta em prejuízo
    BEGIN
      -- Busca saldo da conta em prejuízo
      OPEN cr_sld;
      FETCH cr_sld INTO vr_sldprj;
      CLOSE cr_sld;

      -- Retornar valor encontrado
      RETURN nvl(vr_sldprj,0);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_obtem_saldo_hist_preju_cc;

  -- Retornar o valor do prejuízo da conta corrente conforme a data para o Informe de Rendimentos
  PROCEDURE pc_obtem_saldo_hist_preju_cc(pr_cdcooper   IN NUMBER --> Código da Cooperativa
                                        ,pr_nrdconta   IN NUMBER --> Número da conta
                                        ,pr_dtmvtolt   IN DATE   --> Data a ser verificada para saber se aonta estava em prejuízo no período
                                        ,pr_vlblqprj  OUT NUMBER ) --> Retorna valor bloqueado prejuizo na data
   IS
    /* .............................................................................

    Programa: pc_obtem_saldo_hist_preju_cc
    Sistema : Ayllos
    Autor   : Odirlei BUsana - AMcom
    Data    : Dezembro/2018                 Ultima atualizacao:

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Retornar o valor do prejuízo da conta corrente conforme a data para o Informe de Rendimentos
    Alteracoes:
    ..............................................................................*/


  BEGIN
  
  
    pr_vlblqprj := fn_obtem_saldo_hist_preju_cc ( pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                                 ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                                 ,pr_dtmvtolt => pr_dtmvtolt); --> Data a ser verificada para saber se aonta estava em prejuízo no período
  
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_vlblqprj := 0;
  END pc_obtem_saldo_hist_preju_cc;


  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB,
                                pr_des_dados IN VARCHAR2,
                                pr_fecha_arq IN BOOLEAN DEFAULT FALSE) IS
  /* .............................................................................

   Programa: pc_escreve_clob
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Rangel (AMcom)
   Data    : Julho/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Escreve um texto numa variável CLOB (atalho para a GENE0002.pc_escreve_xml()).

   Observacao:
   Alteracoes:
   ..............................................................................*/
  BEGIN
     gene0002.pc_escreve_xml(pr_clobdado, vr_texto_completo, pr_des_dados, pr_fecha_arq);
  END;

  PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS
    /* .............................................................................

    Programa: pc_transfere_prejuizo_cc
    Sistema : Aimaro
    Sigla   : PREJ
    Autor   : Rangel Decker  AMcom
    Data    : Maio/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua as transferencias de prejuizo de conta corrente.

    Alteracoes: 21/06/2018 - Popular a tabela TBCC_PREJUIZO quando a conta é transferida para prejuízo.
                            Quantidade de dias em atraso
                            Valor saldo prejuízo Rangel Decker (AMcom)

                28/06/2018 - P450 - Contingência para contas não transferidas para prejuízo - Diego Simas - AMcom

    ..............................................................................*/

    --Busca contas correntes que estão na situação de prejuizo
    CURSOR cr_crapris (pr_cdcooper      crapris.cdcooper%TYPE,
                       pr_dtrefere      crapris.dtrefere%TYPE,
                       pr_dtmvtolt      crapris.dtrefere%TYPE
                      -- pr_valor_arrasto crapris.vldivida%TYPE
                       ) IS

      SELECT  ris.nrdconta,
              ris.dtdrisco,
              pass.cdsitdct,
              ris.vldivida,
              ris.dtrefere,
              ris.qtdiaatr
       FROM crapris ris,
             crapass pass
       WHERE pass.inprejuz = 0
       AND   ris.cdcooper  = pass.cdcooper
       AND   ris.nrdconta  = pass.nrdconta
       AND   ris.cdcooper  = pr_cdcooper
       AND   ris.cdmodali  = 101  --ADP
       AND   ris.innivris  = 9    -- Situação H
       AND  (pr_dtmvtolt - ris.dtdrisco) >= 180  -- dias_risco
       AND   ris.qtdiaatr >=180 -- dias_atraso
       AND NOT EXISTS (SELECT 1
                         FROM crapcyc cyc
                        WHERE cyc.cdcooper = ris.cdcooper
                          AND cyc.nrdconta = ris.nrdconta
                                                    AND cyc.cdorigem = 1
                          AND cyc.cdmotcin = 2)
       AND   ris.dtrefere =  pr_dtrefere;
      rw_crapris  cr_crapris%ROWTYPE;

      rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

      vr_des_erro  VARCHAR2(1000);

      vr_dtrefere_aux  DATE;
      vr_diasrisco NUMBER:= 0;

      vr_tab_erro cecred.gene0001.typ_tab_erro;
      vr_possui_erro   BOOLEAN :=FALSE;
  BEGIN
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat
      INTO rw_crapdat;

      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;

        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;

      --Verificar data
      IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
          -- Utilizar o final do mês como data
          vr_dtrefere_aux := rw_crapdat.dtultdma;
      ELSE
          -- Utilizar a data atual
          vr_dtrefere_aux := rw_crapdat.dtmvtoan;
      END IF;

      --Transfere as contas em prejuizo para a tabela TBCC_PREJUIZO...
      FOR rw_crapris IN cr_crapris(pr_cdcooper
                                 , vr_dtrefere_aux
                                 , rw_crapdat.dtmvtolt) LOOP

        pc_grava_prejuizo_cc(pr_cdcooper       => pr_cdcooper,
                             pr_nrdconta       => rw_crapris.nrdconta,
                             pr_tpope          => 'N',
                             pr_cdcritic => vr_cdcritic,
                             pr_dscritic => vr_dscritic,
                             pr_des_erro => vr_des_erro);

        -- Testar se houve erro
        IF vr_des_erro <> 'OK' THEN
          BEGIN
             IF vr_possui_erro = FALSE THEN
             --Montar cabeçalho arquivo csv
             dbms_lob.createtemporary(vr_clobarq, TRUE, dbms_lob.CALL);
             dbms_lob.open(vr_clobarq, dbms_lob.lob_readwrite);

             pc_escreve_clob(vr_clobarq,'Cooperativa; Conta; Risco; Dias no Risco; Dias de atraso; Motivo'||chr(13));


            END IF;
             vr_possui_erro:=TRUE;
            -- ASSUNTO: Atenção! Houve erro na transferência para prejuízo.
            -- EMAIL: recuperacaodecredito@cecred.coop.br
            -- ARQUIVO ANEXO DEVE CONTER: cooperativa, conta, risco, dias no risco,
            --                            dias de atraso e motivo pelo qual a conta
            --                            não foi transferida.
            -- 'Erro na transferecia de prejuizo (Transferencia Automatica).'

          vr_diasrisco := rw_crapdat.dtmvtolt - rw_crapris.dtdrisco;

          -- Escreve linha CSV
          pc_escreve_clob(vr_clobarq, pr_cdcooper ||';' -- Cooperativa
                        ||gene0002.fn_mask(rw_crapris.nrdconta,'z.zzz.zz9')||';' -- Conta
                        ||'H'||';' -- Risco
                        ||to_char(vr_diasrisco)||';' -- Dias no Risco
                        ||to_char(rw_crapris.qtdiaatr)||';' -- Dias de Atraso
                        ||'Erro na transferecia de prejuizo (Transferencia Automatica).'||vr_dscritic||';' -- Motivo
                        ||chr(13));

          END;

          ROLLBACK;
        ELSE
          COMMIT;
        END IF;
    END LOOP;

    -- Se houve erros de transferência e necessita enviar o e-mail de contingência
    IF vr_possui_erro = TRUE THEN
        pc_escreve_clob(vr_clobarq,chr(13),true);
        pc_erro_transfere_prejuizo(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_clobarq => vr_clobarq,
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic,
                                   pr_tab_erro => vr_tab_erro);
    END IF;
  END pc_transfere_prejuizo_cc;
--

 PROCEDURE pc_grava_prejuizo_cc(pr_cdcooper       IN crapcop.cdcooper%TYPE   --> Coop conectada
                                ,pr_nrdconta      IN  crapass.nrdconta%TYPE  --> NR da Conta
                                ,pr_tpope         IN VARCHAR2 DEFAULT 'N'    --> Tipo de Operação(N-Normal F-Fraude)
                                ,pr_cdcritic      OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                ,pr_dscritic      OUT VARCHAR2               --> Descrição da Critica
                                ,pr_des_erro      OUT VARCHAR2) IS
  /* .............................................................................

   Programa: pc_grava_prejuizo_cc
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Julho/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Transfere efetivamente uma conta corrente para prejuízo.

   Observacao:
   Alteracoes:
   ..............................................................................*/

    -- Verifica se a conta já está marcada como "em preuízo"
    CURSOR cr_crapass  (pr_cdcooper  crapass.cdcooper%TYPE,
                        pr_nrdconta  crapass.nrdconta%TYPE) IS
     SELECT a.inprejuz
          , a.vllimcre
          , a.cdsitdct
       FROM crapass a
      WHERE a.cdcooper = pr_cdcooper
        AND a.nrdconta   = pr_nrdconta;
    rw_crapass  cr_crapass%ROWTYPE;

        -- Verifica se há registro com motivo de ação judicial na CRAPCYC
        CURSOR cr_crapcyc(pr_cdcooper crapass.cdcooper%TYPE
                        , pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT 1
              FROM crapcyc cyc
             WHERE cyc.cdcooper = pr_cdcooper
                 AND cyc.nrdconta = pr_nrdconta
                 AND cyc.cdmotcin = 2;

    --Busca contas correntes que estão na situação de prejuizo
    CURSOR cr_crapris (pr_cdcooper      crapris.cdcooper%TYPE,
                       pr_nrdconta      crapris.nrdconta%TYPE,
                       pr_dtrefere      crapris.dtrefere%TYPE,
                       pr_dtmvtolt      crapris.dtrefere%TYPE) IS

      SELECT  ris.dtdrisco,
              ris.vldivida,
              ris.dtrefere,
              ris.qtdiaatr
       FROM  crapris ris,
             crapass pass
       WHERE pass.inprejuz = 0
       AND   ris.cdcooper  = pass.cdcooper
       AND   ris.nrdconta  = pass.nrdconta
       AND   ris.cdcooper  = pr_cdcooper
       AND   ris.nrdconta  = pr_nrdconta
       AND   ris.cdmodali  = 101  --ADP
       AND   ris.dtrefere  = pr_dtrefere
       AND   pr_dtmvtolt - ris.dtdrisco >= 180  -- dias_risco
       AND   ris.qtdiaatr  >= 180 -- dias_atraso
       AND  ris.nrdconta  NOT IN   (SELECT cyc.nrdconta
                                    FROM   crapcyc cyc
                                    WHERE cyc.cdcooper = ris.cdcooper
                                    AND   cyc.nrdconta = ris.nrdconta
                                                                        AND   cyc.cdorigem = 1
                                    AND   cyc.cdmotcin = 2);

    rw_crapris  cr_crapris%ROWTYPE;

    -- Busca dias de atraso da conta transferida por fraude
    CURSOR cr_qtdiaatr(pr_cdcooper      crapris.cdcooper%TYPE,
                       pr_nrdconta      crapris.nrdconta%TYPE,
                       pr_dtrefere      crapris.dtrefere%TYPE) IS
      SELECT ris.qtdiaatr
       FROM  crapris ris
       WHERE ris.cdcooper  = pr_cdcooper
       AND   ris.nrdconta  = pr_nrdconta
       AND   ris.cdmodali  = 101  --ADP
       AND   ris.dtrefere  = pr_dtrefere;

    --Variaveis de critica
    vr_cdcritic  NUMBER(3);
    vr_dscritic  VARCHAR2(1000);
    vr_des_erro  VARCHAR2(1000);

    --Variavel de exceção
    vr_exc_saida exception;

    --Data da cooperativa
    rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

    --Variaveis para lançamentos de débito
    vr_rw_craplot  LANC0001.cr_craplot%ROWTYPE;
    vr_tab_retorno LANC0001.typ_reg_retorno; -- REcord com dados retornados pela "pc_gerar_lancamento_conta"
    vr_incrineg   PLS_INTEGER;

    --Tipo da tabela de saldos
    vr_tab_saldo EXTR0001.typ_tab_saldos;

    -- Variáveis para busca do saldo devedor
    vr_vlslddev  NUMBER:= 0;
    vr_dtrefere_aux  DATE;
    vr_tab_erro cecred.gene0001.typ_tab_erro;

    vr_qtdiaatr crapris.qtdiaatr%TYPE;

    -- Valores de juros +60
    vr_vlhist37 NUMBER;
    vr_vlhist38 NUMBER;
    vr_vlhist57 NUMBER;

        vr_vljuro60_37 NUMBER; -- Juros +60 (Hist. 37 + Hist. 2718)
        vr_vljuro60_38 NUMBER; -- Juros +60 (Hist. 38)
        vr_vljuro60_57 NUMBER; -- Juros +60 (Hist. 57)

    vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
        vr_existecyc INTEGER;
  BEGIN
      pr_des_erro:='OK';

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat
      INTO rw_crapdat;

      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;

        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;

      --Verificar se está executando no primeiro dia útil do mês
      IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
          -- Utiliza o dia da última mensal como data
          vr_dtrefere_aux := rw_crapdat.dtultdma;
      ELSE
          -- Utiliza a data atual
          vr_dtrefere_aux := rw_crapdat.dtmvtoan;
      END IF;

     -- Verifica se a cooperativa esta cadastrada
     OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
     FETCH cr_crapass INTO rw_crapass;

     IF cr_crapass%NOTFOUND THEN
       CLOSE cr_crapass;
       vr_cdcritic:= 651;
       RAISE vr_exc_saida;
     ELSE
       CLOSE cr_crapass;
     END IF;

     -- Verifica se a conta está marcada como "em prejuízo" (para o caso de transferência forçada)
     IF rw_crapass.inprejuz = 1 THEN
       vr_cdcritic := 0;
       vr_dscritic := 'A conta informada já está marcada como "Em prejuízo".';

       RAISE vr_exc_saida;
     END IF;

         IF pr_tpope <> 'N' THEN
             OPEN cr_crapcyc(pr_cdcooper, pr_nrdconta);
             FETCH cr_crapcyc INTO vr_existecyc;

             IF cr_crapcyc%FOUND THEN
                 CLOSE cr_crapcyc;

                  vr_cdcritic := 0;
          vr_dscritic := 'A conta encontra-se marcada como "Determinação Judicial" na CADCYB.';

          RAISE vr_exc_saida;
             END IF;

             CLOSE cr_crapcyc;
         END IF;

     -- Cancela produtos/serviços da conta (cartão magnético, senha da internet, limite de crédito)
     pc_cancela_servicos_cc_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtinc_prejuizo => rw_crapdat.dtmvtolt
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

     IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) is not NULL THEN
       vr_cdcritic:= 0;
       vr_dscritic:= 'Erro ao cancelar produtos/serviços para a conta ' || pr_nrdconta;

       RAISE vr_exc_saida;
     END IF;

     -- Identificar valores provisionados de juros +60 e debitar na conta
     pc_debita_juros60_prj(pr_cdcooper => pr_cdcooper
                         , pr_nrdconta => pr_nrdconta
                         , pr_vlhist37 => vr_vlhist37
                         , pr_vlhist38 => vr_vlhist38
                         , pr_vlhist57 => vr_vlhist57
                         , pr_cdcritic => vr_cdcritic
                         , pr_dscritic => vr_dscritic);

     IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) is not NULL THEN
       vr_cdcritic:= 0;
       vr_dscritic:= 'Erro ao debitar valores provisionados de juros +60 para conta ' || pr_nrdconta;

       RAISE vr_exc_saida;
     END IF;

     -- Busca saldo devedor (saldo até 59 dias de atraso) e juros +60 não pagos da conta
         TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60_det(pr_cdcooper => pr_cdcooper
                                                   , pr_nrdconta => pr_nrdconta
                                                   , pr_vlsld59d => vr_vlslddev
                                                                                                     , pr_vlju6037 => vr_vljuro60_37
                                                                                                     , pr_vlju6038 => vr_vljuro60_38
                                                                                                     , pr_vlju6057 => vr_vljuro60_57
                                                   , pr_cdcritic => vr_cdcritic
                                                   , pr_dscritic => vr_dscritic);

     IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) is not NULL THEN
       vr_cdcritic:= 0;
       vr_dscritic:= 'Erro ao recuperar saldo devedor da conta corrente ' || pr_nrdconta;

       RAISE vr_exc_saida;
     END IF;

     IF pr_tpope = 'N' THEN -- Transferência normal (180 dias de atraso e 180 dias no risco H)
       -- Busca dados da conta na central de risco
       OPEN cr_crapris( pr_cdcooper      => pr_cdcooper
                       ,pr_nrdconta      => pr_nrdconta
                       ,pr_dtrefere      => vr_dtrefere_aux
                       ,pr_dtmvtolt      => rw_crapdat.dtmvtolt);
       FETCH cr_crapris INTO rw_crapris;

       IF cr_crapris%NOTFOUND THEN
         CLOSE cr_crapris;

         vr_cdcritic:= 0;
         vr_dscritic:='Conta não atende às regras de transferência para prejuízo.';

         RAISE vr_exc_saida;
       ELSE
         CLOSE cr_crapris;

         vr_qtdiaatr := rw_crapris.qtdiaatr;
       END IF;
     ELSE -- Transferência por fraude (forçada)
        OPEN cr_qtdiaatr(pr_cdcooper      => pr_cdcooper
                         ,pr_nrdconta      => pr_nrdconta
                         ,pr_dtrefere      => vr_dtrefere_aux);
        FETCH cr_qtdiaatr INTO vr_qtdiaatr;

        IF cr_qtdiaatr%NOTFOUND THEN
          vr_qtdiaatr := 0;
        END IF;

        CLOSE cr_qtdiaatr;
     END IF;

     BEGIN
       INSERT INTO TBCC_PREJUIZO(cdcooper
                                ,nrdconta
                                ,dtinclusao
                                ,cdsitdct_original
                                ,vldivida_original
                                ,qtdiaatr
                                ,vlsdprej
                                ,vljur60_ctneg
                                ,vljur60_lcred
                                ,intipo_transf)
       VALUES (pr_cdcooper,
               pr_nrdconta,
               rw_crapdat.dtmvtolt,
               rw_crapass.cdsitdct,
                             vr_vlslddev + vr_vljuro60_37 + vr_vljuro60_57 + vr_vljuro60_38,
               vr_qtdiaatr,
               vr_vlslddev,
                             vr_vljuro60_37 + vr_vljuro60_57,
                             vr_vljuro60_38,
               CASE WHEN pr_tpope = 'N' THEN 0 ELSE 1 END)
       RETURNING idprejuizo INTO vr_idprejuizo;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:=0;
          vr_dscritic := 'Erro de insert na TBCC_PREJUIZO: '||SQLERRM;
        RAISE vr_exc_saida;
     END;

     BEGIN
       --Transfere conta para prejuizo AQUI
       UPDATE crapass pass
          SET --pass.cdsitdct = 2, -- 2-Em Prejuizo  -- Comentado por Ornelas, pois está na nova rotina pc_define_situacao_cc_prej
              pass.inprejuz = 1
        WHERE pass.cdcooper = pr_cdcooper
          AND pass.nrdconta = pr_nrdconta;
     EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:=0;
          vr_dscritic := 'Erro de update na CRAPASS: '||SQLERRM;
        RAISE vr_exc_saida;
     END;
     -- ornelas
     -- Grava situação da conta corrente antes da transferência para Prejuizo
     pc_define_situacao_cc_prej(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_cdcritic => vr_cdcritic 
                                        ,pr_dscritic => vr_dscritic );
                                         
     if nvl(vr_cdcritic,0) > 0  or TRIM(vr_dscritic) is not null then
         RAISE vr_exc_saida;
     end if;    

     -- Registra as informações da transferência no extrato do prejuízo
     pc_lanca_transf_extrato_prj(pr_idprejuizo => vr_idprejuizo
                               , pr_cdcooper   => pr_cdcooper
                               , pr_nrdconta   => pr_nrdconta
                               , pr_vlsldprj   => vr_vlslddev
                                                             , pr_vljur60_ctneg => vr_vljuro60_37 + vr_vljuro60_57
                                                             , pr_vljur60_lcred => vr_vljuro60_38
                               , pr_dtmvtolt   => rw_crapdat.dtmvtolt
                               , pr_tpope      => pr_tpope
                               , pr_cdcritic   => vr_cdcritic
                               , pr_dscritic   => vr_dscritic);
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
  END   pc_grava_prejuizo_cc;

 PROCEDURE pc_cancela_servicos_cc_prj(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Coop conectada
                               ,pr_nrdconta       IN crapass.nrdconta%TYPE --> NR da Conta
                               ,pr_dtinc_prejuizo IN crapris.dtinictr%TYPE --> Data que entrou em prejuizo
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Critica encontrada
                               ,pr_dscritic OUT VARCHAR2 ) IS
  /* .............................................................................

   Programa: pc_cancela_servicos_cc_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Cancela os serviços de cartão magnético, senha de acesso ao internet banking
                 e o limite de crédito da conta que está sendo transferida para prejuízo.

   Observacao:
   Alteracoes:
   ..............................................................................*/

   --Numero de contrato de limite de credito ativo
   CURSOR cr_craplim (pr_cdcooper craplim.cdcooper%TYPE,
                        pr_nrdconta craplim.nrdconta%TYPE   ) IS
      SELECT  lim.nrctrlim
      FROM craplim lim
      WHERE lim.cdcooper = pr_cdcooper
      AND   lim.nrdconta = pr_nrdconta
      AND   lim.insitlim = 2;
    rw_craplim  cr_craplim%ROWTYPE;

    --Cartões magneticos ativos
    CURSOR  cr_crapcrm  (pr_cdcooper crapcrm.cdcooper%TYPE,
                         pr_nrdconta crapcrm.nrdconta%TYPE) IS
     SELECT crm.nrcartao
     FROM crapcrm crm
     WHERE crm.cdcooper = pr_cdcooper
     AND  crm.nrdconta  = pr_nrdconta
     AND  crm.cdsitcar  = 2;
    rw_crapcrm  cr_crapcrm%ROWTYPE;


    vr_tab_msg_confirm cada0003.typ_tab_msg_confirma;
    vr_tab_erro cecred.gene0001.typ_tab_erro;
    vr_des_erro  VARCHAR2(1000);

    vr_cdcritic  NUMBER(3);
    vr_dscritic  VARCHAR2(1000);
    vr_des_reto VARCHAR2(100);
  BEGIN
        --Cancela Internet Banking
         CADA0003.pc_cancelar_senha_internet(pr_cdcooper =>pr_cdcooper                 --Cooperativa
                                             ,pr_cdagenci => 0                          --Agência
                                             ,pr_nrdcaixa => 0                          --Caixa
                                             ,pr_cdoperad => '1'                        --Operador
                                             ,pr_nmdatela => 'PC_CANCELAR_SENHA_INTERNET' --Nome da tela
                                             ,pr_idorigem => 1                          --Origem
                                             ,pr_nrdconta => pr_nrdconta                --Conta
                                             ,pr_idseqttl => 1                          --Sequência do titular
                                             ,pr_dtmvtolt => pr_dtinc_prejuizo          --Data de movimento
                                             ,pr_inconfir => 3                          --Controle de confirmação
                                             ,pr_flgerlog => 0                          --Gera log
                                             ,pr_tab_msg_confirma => vr_tab_msg_confirm
                                             ,pr_tab_erro => vr_tab_erro--Registro de erro
                                             ,pr_des_erro => vr_des_erro);            --Saida OK/NOK

            --Se Ocorreu erro
           IF vr_des_erro <> 'OK' THEN

              --Se possuir erro na tabela
              IF vr_tab_erro.COUNT > 0 THEN

                --Mensagem Erro
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;

              ELSE
                --Mensagem Erro
                vr_dscritic:= 'Erro na pc_cancelar_senha_internet.';
              END IF;

           END IF;

           --Verifica se existe contrato de limite ativo para conta
           OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta );
           FETCH cr_craplim
           INTO rw_craplim;
           -- Se não encontrar
           IF cr_craplim%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craplim;
           ELSE
             --Cancelamento Limite de Credito
           LIMI0002.pc_cancela_limite_credito(pr_cdcooper   => pr_cdcooper                -- Cooperativa
                                               ,pr_cdagenci   => 0                          -- Agência
                                               ,pr_nrdcaixa   => 0                          -- Caixa
                                               ,pr_cdoperad   => '1'                        -- Operador
                                               ,pr_nrdconta   => pr_nrdconta                -- Conta do associado
                                               ,pr_nrctrlim   => rw_craplim.nrctrlim          -- Contrato de Rating
                                               ,pr_inadimp    => 1                          -- 1-Inadimplência 0-Normal
                                               ,pr_cdcritic   => vr_cdcritic                -- Retorno OK / NOK
                                               ,pr_dscritic   => vr_dscritic);              -- Erros do processo


            --Se Ocorreu erro
           IF  vr_cdcritic <>0  OR  vr_dscritic <> ' '  THEN

              --Se possuir erro na tabela
              IF vr_tab_erro.COUNT > 0 THEN

                --Mensagem Erro
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;

              ELSE
                --Mensagem Erro
                vr_dscritic:= 'Erro na pc_cancelar_senha_internet.';
              END IF;

             pr_cdcritic := vr_cdcritic;
             pr_dscritic := vr_dscritic;

           END IF;

           CLOSE cr_craplim;
         END IF;


           --Verifica se existe cartao ativo para a conta
           OPEN cr_crapcrm(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta);
           FETCH cr_crapcrm
           INTO rw_crapcrm;
           -- Se não encontrar

           IF cr_crapcrm%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapcrm;
           ELSE

               -- Bloqueio cartão magnetico
               cada0004.pc_bloquear_cartao_magnetico( pr_cdcooper => pr_cdcooper, --> Codigo da cooperativa
                                                      pr_cdagenci => 0,  --> Codigo de agencia
                                                      pr_nrdcaixa => 0, --> Numero do caixa
                                                      pr_cdoperad => '1',  --> Codigo do operador
                                                      pr_nmdatela => 'ATENDA', --> Nome da tela
                                                      pr_idorigem => 1,               --> Identificado de origem
                                                      pr_nrdconta => pr_nrdconta,  --> Numero da conta
                                                      pr_idseqttl => 1,  --> sequencial do titular
                                                      pr_dtmvtolt => pr_dtinc_prejuizo,              --> Data do movimento
                                                      pr_nrcartao => rw_crapcrm.nrcartao, --> Numero do cartão
                                                      pr_flgerlog => 'S',                 --> identificador se deve gerar log S-Sim e N-Nao
                                                      ------ OUT ------
                                                      pr_cdcritic  => vr_cdcritic,
                                                      pr_dscritic  => vr_dscritic,
                                                      pr_des_reto  => vr_des_reto);--> OK ou NOK


                IF vr_des_reto <> 'OK' THEN
                   pr_cdcritic := vr_cdcritic;
                   pr_dscritic := vr_dscritic;
                END IF;

              CLOSE cr_crapcrm;
        END IF ;


  END pc_cancela_servicos_cc_prj;

 PROCEDURE pc_erro_transfere_prejuizo(pr_cdcooper       IN crapcop.cdcooper%TYPE  --> Coop conectada
                                      ,pr_dtmvtolt       IN crapdat.dtmvtolt%TYPE  --> Data do movimento atual
                                      ,pr_clobarq        IN OUT NOCOPY CLOB                                            --> clob para conter o dados do excel/csv
                                      ,pr_cdcritic       OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic       OUT VARCHAR2              -->Descrição Critica
                                      ,pr_tab_erro       OUT gene0001.typ_tab_erro) IS
  /* .............................................................................

   Programa: pc_cancela_servicos_cc_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Envia e-mail com relatório caso haja problemas ao transferir as contas corrente
                 para prejuízo.

   Observacao:
   Alteracoes:
   ..............................................................................*/

     vr_nom_direto  VARCHAR2(100); -- diretorio de geracao do relatorio
     vr_nmarqimp  VARCHAR2(50);
  BEGIN


    -- Busca do diretório base da cooperativa para CSV
     vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper); --> Utilizaremos o rl


     vr_mailprej := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => pr_cdcooper, pr_cdacesso => 'PREJ0003_EMAILS_PREJU' );

     vr_nmarqimp := 'PREJU_'||replace(pr_dtmvtolt,'/','')||'.csv';

     GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper       --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra               --> Programa chamador
                                       ,pr_dtmvtolt  => pr_dtmvtolt               --> Data do movimento atual
                                       ,pr_dsxml     => pr_clobarq                --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_nom_direto||'/arq/'||vr_nmarqimp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                        --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                        --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'S'                        --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                          --> Número de cópias para impressão
                                       ,pr_dspathcop => vr_nom_direto||'/salvar/'  --> Lista sep. por ';' de diretórios a copiar o arquivo
                                       ,pr_dsmailcop => vr_mailprej                --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail =>'Atencao! Houve erro na '
                                                       ||'transferencia para prejuizo'--> Assunto do e-mail que enviará o arquivo
                                       ,pr_dscormail =>  '<p><b>Em anexo a este '     --> HTML corpo do email que enviará o arquivo
                                          ||'e-mail, segue a lista de contas que'
                                          ||' nao foram transferidas para'
                                          ||' prejuizo</b></p>'
                                       ,pr_fldosmail => 'S'                        --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_des_erro  => vr_dscritic);              --> Retorno de Erro



    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_clobarq);
    dbms_lob.freetemporary(vr_clobarq);
    -- Testar se houve erro
    IF  pr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic ||SQLERRM;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 1
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);


  END pc_erro_transfere_prejuizo;

  PROCEDURE pc_liquida_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                  ,pr_dscritic OUT VARCHAR2
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS


 /* .............................................................................

    Programa: pc_liquida_prejuizo_cc
    Sistema :
    Sigla   : PREJ
    Autor   : Rangel Decker  AMcom
    Data    : Junho/2018.                  Ultima atualizacao: 09/11/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Registra liquidação de prejuízo de conta corrente.

    Alteracoes: 
                09/11/2018 - Ajustes nos cursores da liquidação
                               (Reginaldo/AMcom/P450)                       

                01/02/2019 - P450 - Product Backlog Item 13920:Bugs 2019/2 - Bug 14433:Liquidação prejuízo emprestimo
                             Obs.: não estava relacionado a estória 12556, foi uma alteração feita em momento anterior, 
                             que foi a inclusão do EXISTS no cursor da crapss relacionado a tbcc_prejuizo, e neste
                             momento este foi retirado (Fabio Adriano - AMcom).
    ..............................................................................*/

  -- Recupera informações dos prejuízo a serem liquidados (saldo devedor total igual a zero)
  CURSOR cr_conta_liquida (pr_cdooper  IN tbcc_prejuizo.cdcooper%TYPE) IS
   SELECT tbprj.nrdconta,
          tbprj.cdcooper,
          tbprj.cdsitdct_original,
          tbprj.rowid
     FROM tbcc_prejuizo tbprj
    WHERE tbprj.cdcooper = pr_cdcooper
      AND tbprj.dtliquidacao IS NULL
      AND (tbprj.vlsdprej +
           tbprj.vljuprej +
           tbprj.vljur60_ctneg +
           tbprj.vljur60_lcred) = 0;

  -- Contas não em prejuizo INPREJUZ=0 e com situação em prejuizo CDSITDCT=2
  CURSOR cr_conta_nprej_sitprej IS
   SELECT ass.nrdconta,
          ass.cdcooper 
     FROM crapass ass
    WHERE ass.inprejuz = 0
      AND ass.cdsitdct = 2;     
  rw_cr_conta_nprej_sitprej cr_conta_nprej_sitprej%ROWTYPE;    
  
  -- Prejuizo mais recente
  CURSOR cr_prej_recente (pr_cdcooper  IN crapass.cdcooper%TYPE,     -- tbcc_prejuizo.cdcooper%TYPE,
                          pr_nrdconta IN crapass.nrdconta%TYPE ) IS -- tbcc_prejuizo.nrdconta%TYPE ) IS
    SELECT cdsitdct_original 
          FROM (SELECT DISTINCT
                                         tbprj.dtinclusao,
           tbprj.cdsitdct_original 
    FROM tbcc_prejuizo tbprj
    WHERE tbprj.cdcooper = pr_cdcooper
     AND  tbprj.nrdconta = pr_nrdconta
                        ORDER BY dtinclusao DESC)
        WHERE rownum = 1;
  rw_prej_recente cr_prej_recente%ROWTYPE;

  vr_cdcritic  NUMBER(3);
  vr_dscritic  VARCHAR2(1000);
  vr_des_erro  VARCHAR2(1000);
  vr_exc_saida exception;
  vr_sldconta NUMBER;

  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
 BEGIN
   -- Recupera calendário de datas da cooperativa
   OPEN BTCH0001.cr_crapdat(pr_cdcooper);
   FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
   CLOSE BTCH0001.cr_crapdat;

    FOR rw_cr_conta_nprej_sitprej IN cr_conta_nprej_sitprej LOOP
      BEGIN                              
            
        IF NOT fn_verifica_preju_ativo(pr_cdcooper => rw_cr_conta_nprej_sitprej.cdcooper
                                      ,pr_nrdconta => rw_cr_conta_nprej_sitprej.nrdconta ) THEN
          BEGIN  
                
            OPEN cr_prej_recente(pr_cdcooper => rw_cr_conta_nprej_sitprej.cdcooper 
                                ,pr_nrdconta => rw_cr_conta_nprej_sitprej.nrdconta );
            FETCH cr_prej_recente INTO rw_prej_recente;

            IF cr_prej_recente%FOUND THEN
              UPDATE crapass a
                 SET a.cdsitdct = rw_prej_recente.cdsitdct_original
               WHERE a.cdcooper = rw_cr_conta_nprej_sitprej.cdcooper
                 AND a.nrdconta = rw_cr_conta_nprej_sitprej.nrdconta;       
            END IF;    
               
            CLOSE cr_prej_recente;
          END;   
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic :=99999;
          vr_dscritic := 'Erro ao alterar a situação da conta - CRAPASS. '||SQLERRM;

          -- ********** TROCAR POR gera_log *******************
          RAISE vr_exc_saida;    
      END ;
    END LOOP;  


    -- Percorre a lista dos prejuízos que devem ser liquidados
    FOR rw_conta_liquida IN cr_conta_liquida(pr_cdcooper) LOOP
      -- Restaura a situação da conta corrente e retira a flag de "em prejuízo"
        BEGIN                              
        UPDATE crapass a
                     SET a.inprejuz = 0
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = rw_conta_liquida.nrdconta;
                                         
            IF NOT fn_verifica_preju_ativo(pr_cdcooper => rw_conta_liquida.cdcooper
                                          ,pr_nrdconta => rw_conta_liquida.nrdconta ) THEN           
              UPDATE crapass a
                SET a.cdsitdct = rw_conta_liquida.cdsitdct_original 
              WHERE a.cdcooper = pr_cdcooper
                AND a.nrdconta = rw_conta_liquida.nrdconta;       
            END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic :=99999;
            vr_dscritic := 'Erro ao alterar a situação da conta - CRAPASS. '||SQLERRM;

          -- ********** TROCAR POR gera_log *******************
          RAISE vr_exc_saida;
      END;

      -- Obtém o saldo total da conta transitória
      vr_sldconta:= fn_sld_cta_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => rw_conta_liquida.nrdconta
                                  ,pr_exclbloq => 0);

      IF vr_sldconta > 0 THEN
        -- Gera lançamento para transferência do saldo disponível da conta transitória para a conta corrente
        pc_gera_transf_cta_prj(pr_cdcooper  => pr_cdcooper               --> Código da Cooperativa
                           ,pr_nrdconta => rw_conta_liquida.nrdconta --> Número da conta
                           ,pr_cdoperad => 1                         --> Código do Operador
                           ,pr_vllanmto => vr_sldconta               --> Valor do Lançamento
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_versaldo => 0                         --> Não valida o saldo disponível
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

        IF nvl(vr_cdcritic, 0) <> 0 OR vr_dscritic IS NOT NULL THEN
           -- ********** TROCAR POR gera_log *******************
           RAISE vr_exc_saida;
        END IF;
      END IF;

      BEGIN
        -- Zero o saldo disponível para operações na conta corrente
        UPDATE tbcc_prejuizo tbprj
           SET tbprj.vlsldlib     = 0
                       , tbprj.dtliquidacao = rw_crapdat.dtmvtolt
         WHERE tbprj.cdcooper     = pr_cdcooper
           AND tbprj.rowid        = rw_conta_liquida.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 99999;
          vr_dscritic := 'Erro ao atualizar a tabela TBCC_PREJUIZO. ' || SQLERRM;

          -- ********** TROCAR POR gera_log *******************
          RAISE vr_exc_saida;
      END;
    END LOOP;

        COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic ||SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                ROLLBACK;
 END  pc_liquida_prejuizo_cc;

  PROCEDURE pc_consulta_sld_cta_prj(pr_cdcooper IN NUMBER             --> Código da Cooperativa
                                   ,pr_nrdconta IN NUMBER             --> Número da conta
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS

    /* .............................................................................

        Programa: pc_consulta_sld_cta_prj
        Sistema : CECRED
        Sigla   : PREJ
        Autor   : Daniel/AMcom
        Data    : Junho/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar saldo de conta em Prejuízo
        Observacao: -----
        Alteracoes:
      ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    BEGIN
      pr_des_erro := 'OK';

      -- PASSA OS DADOS PARA O XML RETORNO
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => 0,
                             pr_tag_nova => 'saldo',
                             pr_tag_cont => fn_sld_cta_prj(pr_cdcooper
                                                          ,pr_nrdconta),
                             pr_des_erro => vr_dscritic);
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
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro não tratado na rotina PREJ0003.pc_consulta_sld_cta_prj: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_consulta_sld_cta_prj;

PROCEDURE pc_gera_lcm_cta_prj(pr_cdcooper  IN NUMBER             --> Código da Cooperativa
                             ,pr_nrdconta  IN NUMBER             --> Número da conta
                             ,pr_cdoperad  IN VARCHAR2           --> Código do Operador
                             ,pr_vlrlanc   IN NUMBER             --> Valor do Lançamento
                             ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic  OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2) IS      --> Erros do processo

/* .............................................................................

        Programa: pc_gera_lcm_cta_prj
        Sistema : CECRED
        Sigla   : PREJ
        Autor   : Daniel/AMcom
        Data    : Junho/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para efetuar lançamento em conta Prejuízo
        Observacao: -----
        Alteracoes:
      ..............................................................................*/

      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic crapcri.dscritic%TYPE; --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
      pr_des_erro := 'OK';

      OPEN BTCH0001.cr_crapdat(pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Efetua a transferência da conta transitória para a conta corrente
      pc_gera_transf_cta_prj(pr_cdcooper => pr_cdcooper
                           , pr_nrdconta => pr_nrdconta
                           , pr_cdoperad => pr_cdoperad
                           , pr_vllanmto => pr_vlrlanc
                           , pr_dtmvtolt => rw_crapdat.dtmvtolt
                           , pr_cdcritic => vr_cdcritic
                           , pr_dscritic => vr_dscritic);

     IF vr_dscritic <> NULL THEN
       RAISE vr_exc_saida;
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

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro não tratado na rotina PREJ0003.pr_gera_lcm_cta_prj: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_gera_lcm_cta_prj;

  PROCEDURE pc_gera_transf_cta_prj(pr_cdcooper IN NUMBER
                                , pr_nrdconta IN NUMBER
                                , pr_cdoperad IN VARCHAR2 DEFAULT '1'
                                , pr_vllanmto IN NUMBER
                                , pr_dtmvtolt IN DATE
                                , pr_versaldo IN INTEGER DEFAULT 1 -- Se deve validar o saldo disponível
                                , pr_atsldlib IN INTEGER DEFAULT 1 -- Se deve atualizar o saldo disponível para operações na conta corrente (VLSLDLIB)
                                , pr_dsoperac IN VARCHAR2 DEFAULT NULL -- Descrição da operação que originou a transferência
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* .............................................................................

   Programa: pc_gera_transf_cta_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao: 02/05/2019

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Gera lançamentos de transferência de valor entre a conta transitória e a conta corrente.

   Observacao:
   Alteracoes:
      13/02/2019 - Correção bug nos retornos das variáveis de erro e tratamentos de erro
                   Renato Cordeiro - AMcom
         
               02/05/2019 - P450 - Inclusão do parâmetro opcional para a descrição da operação que originou a transferência
                            (Reginaldo/AMcom)                                          
         
   ..............................................................................*/

      vr_incrineg      INTEGER; --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
      vr_tab_retorno   LANC0001.typ_reg_retorno;
      vr_nrseqdig     NUMBER     := 0;
      vr_nrdocmto     NUMBER(25) := 0;
      vr_nrdocmto_prj NUMBER(25) := 0;

      vr_exc_saida EXCEPTION;
  BEGIN
      pr_cdcritic := 0;
      pr_dscritic := NULL;

      -- Verifica se há saldo disponível para a transferência
      IF pr_versaldo = 1 AND pr_vllanmto > fn_sld_cta_prj(pr_cdcooper => pr_cdcooper
                                                        , pr_nrdconta => pr_nrdconta
                                                        , pr_exclbloq => 1) THEN

        vr_cdcritic := 0;
        vr_dscritic := 'Erro: Saldo insuficiente para a transferência do valor.';

        RAISE vr_exc_saida;
      END IF;

      -- Buscar Documento CRAPLCM
      BEGIN
        SELECT NVL(MAX(lcm.nrdocmto)+1, 1)
          INTO vr_nrdocmto
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = pr_nrdconta
           AND lcm.dtmvtolt = pr_dtmvtolt;
      EXCEPTION
        WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao buscar número do documento na CRAPLCM';

        RAISE vr_exc_saida;
      END;

      -- Cria lançamento de débito na conta transitória (TBCC_PREJUIZO_LANCAMENTO)
      pc_gera_debt_cta_prj(pr_cdcooper => pr_cdcooper
                         , pr_nrdconta => pr_nrdconta
                         , pr_cdoperad => pr_cdoperad
                         , pr_vlrlanc =>  pr_vllanmto
                         , pr_dtmvtolt => pr_dtmvtolt
                         , pr_dsoperac => pr_dsoperac 
                         , pr_cdcritic => vr_cdcritic
                         , pr_dscritic => vr_dscritic);

      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        IF vr_incrineg = 0 THEN
          RAISE vr_exc_saida;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir lançamento (LANC0001)';

          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Gera valor do campo "nrseqdig" a partir da sequence (para não usar CRAPLOT)
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(pr_dtmvtolt, 'DD/MM/RRRR') ||';'||
                                '1;100;650010');

      -- Efetua lancamento de crédito na CRAPLCM(LANC0001)
      LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_cdagenci => 1
                                        ,pr_cdbccxlt => 100
                                        ,pr_nrdolote => 650010
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdocmto => vr_nrdocmto
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nrdctabb => pr_nrdconta
                                        ,pr_nrseqdig => vr_nrseqdig
                                        ,pr_dtrefere => pr_dtmvtolt
                                        ,pr_vllanmto => pr_vllanmto
                                        ,pr_cdhistor => 2720
                                        -- OUTPUT --
                                        ,pr_tab_retorno => vr_tab_retorno
                                        ,pr_incrineg => vr_incrineg
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
      END IF;

      IF pr_atsldlib = 1 THEN
                -- Atualiza o valor do saldo disponível para operações na C/C
                UPDATE tbcc_prejuizo
                     SET vlsldlib = vlsldlib + pr_vllanmto
                 WHERE cdcooper = pr_cdcooper
                     AND nrdconta = pr_nrdconta
                     AND dtliquidacao IS NULL;
            END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
  END pc_gera_transf_cta_prj;

  PROCEDURE pc_gera_debt_cta_prj(pr_cdcooper  IN NUMBER                 --> Código da Cooperativa
                                 ,pr_nrdconta  IN NUMBER                --> Número da conta
                                 ,pr_cdoperad  IN VARCHAR2 DEFAULT '1'  --> Código do Operador
                                 ,pr_vlrlanc   IN NUMBER                --> Valor do Lançamento
                                 ,pr_dtmvtolt  IN DATE                  --> Data da cooperativa
                                 ,pr_dsoperac  IN VARCHAR2 DEFAULT NULL --> Descrição breve da operação que originou o débito (Ex. Pagamento de empréstimo, bloqueio de acordo, etc)
                                 ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2) IS         --> Descrição da crítica
/* .............................................................................

   Programa: pc_gera_debt_cta_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao: 02/05/2019

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Gera lançamento de débito na conta transitória.

   Observacao:
   Alteracoes: 02/05/2019 - P450 - Inclusão de parâmetro opcional para a descrição da operação que originou o débito
                            (Reginaldo/AMcom)
                             
   ..............................................................................*/


      -- Outras
      vr_nrdocmto_prj NUMBER(25) := 0;
  BEGIN
      -- Buscar Documento TBCC_PREJUIZO_LANCAMENTO
        BEGIN
          SELECT nvl(MAX(t.nrdocmto)+1, 1)
            INTO vr_nrdocmto_prj
            FROM tbcc_prejuizo_lancamento t
           WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.cdhistor = 2739
             AND t.dtmvtolt = pr_dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro Buscar Documento TBCC_PREJUIZO_LANCAMENTO';
          RAISE vr_exc_saida;
        END;

      -- Efetua lancamento de débito na contra transitória
      BEGIN
        INSERT INTO tbcc_prejuizo_lancamento(dtmvtolt
                                            ,cdagenci
                                            ,nrdconta
                                            ,cdhistor
                                            ,nrdocmto
                                            ,vllanmto
                                            ,dthrtran
                                            ,cdoperad
                                            ,cdcooper
                                            ,dsoperac)
                                      VALUES(pr_dtmvtolt      -- dtmvtolt
                                            ,1                -- cdagenci
                                            ,pr_nrdconta      -- nrdconta
                                            ,2739             -- cdhistor
                                            ,vr_nrdocmto_prj  -- nrdocmto
                                            ,nvl(pr_vlrlanc,0)-- vllanmto
                                            ,SYSDATE  -- dthrtran
                                            ,pr_cdoperad     -- cdoperad
                                            ,pr_cdcooper
                                            ,pr_dsoperac);    -- cooperativa
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro de insert na TBCC_PREJUIZO_LANCAMENTO:'||SQLERRM;
          RAISE vr_exc_saida;
      END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina PREJ0003.pc_gera_debt_cta_prj: ' || SQLERRM;
END pc_gera_debt_cta_prj;

PROCEDURE pc_gera_cred_cta_prj(pr_cdcooper  IN NUMBER                 --> Código da Cooperativa
                              ,pr_nrdconta  IN NUMBER                --> Número da conta
                              ,pr_cdoperad  IN VARCHAR2 DEFAULT '1'  --> Código do Operador
                              ,pr_vlrlanc   IN NUMBER                --> Valor do Lançamento
                              ,pr_dtmvtolt  IN DATE                  --> Data da cooperativa
                              ,pr_nrdocmto  IN tbcc_prejuizo_lancamento.nrdocmto%TYPE DEFAULT NULL
                              ,pr_dsoperac  IN VARCHAR2 DEFAULT NULL --> Descrição da operação que originou o crédito (Ex. Desbloqueio de acordo, Liberação de crédito de empréstimo, etc)
                              ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic  OUT VARCHAR2) IS         --> Descrição da crítica
/* .............................................................................

   Programa: pc_gera_cred_cta_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao: 02/05/2019

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Gera lançamento de crédito na conta transitória.

   Observacao:
   Alteracoes: 02/05/2019 - P450 - Inclusão de parâmetro opcional para a descrição da operação que originou o crédito
                            (Reginaldo/AMcom)
                            
   ..............................................................................*/

      vr_nrdocmto_prj tbcc_prejuizo_lancamento.nrdocmto%TYPE := pr_nrdocmto;
  BEGIN
          IF vr_nrdocmto_prj IS NULL THEN
        -- Buscar Documento TBCC_PREJUIZO_LANCAMENTO
        BEGIN
          SELECT nvl(MAX(t.nrdocmto)+1, 1)
            INTO vr_nrdocmto_prj
            FROM tbcc_prejuizo_lancamento t
           WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.cdhistor = 2738
             AND t.dtmvtolt = pr_dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro Buscar Documento TBCC_PREJUIZO_LANCAMENTO';
          RAISE vr_exc_saida;
        END;
          END IF;

      -- Efetua lancamento de débito na contra transitória
      BEGIN
        INSERT INTO tbcc_prejuizo_lancamento(dtmvtolt
                                            ,cdagenci
                                            ,nrdconta
                                            ,cdhistor
                                            ,nrdocmto
                                            ,vllanmto
                                            ,dthrtran
                                            ,cdoperad
                                            ,cdcooper
                                            ,dsoperac)
                                      VALUES(pr_dtmvtolt      -- dtmvtolt
                                            ,1                -- cdagenci
                                            ,pr_nrdconta      -- nrdconta
                                            ,2738             -- cdhistor
                                            ,vr_nrdocmto_prj  -- nrdocmto
                                            ,nvl(pr_vlrlanc,0)-- vllanmto
                                            ,SYSDATE  -- dthrtran
                                            ,pr_cdoperad     -- cdoperad
                                            ,pr_cdcooper
                                            ,pr_dsoperac);    -- cooperativa
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro de insert na TBCC_PREJUIZO_LANCAMENTO:'||SQLERRM;
          RAISE vr_exc_saida;
      END;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina PREJ0003.pc_gera_cred_cta_prj: ' || SQLERRM;
END pc_gera_cred_cta_prj;

PROCEDURE pc_ret_saldo_dia_prej ( pr_cdcooper  IN crapcop.cdcooper%TYPE         --> Coop conectada
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE         --> Numero da conta
                                 ,pr_dtmvtolt  IN DATE                          --> Data incio do periodo do prejuizo
                                 ,pr_exclbloq  IN NUMBER DEFAULT 0              --> Se deve subtrair os créditos bloqueados
                                 ,pr_vldsaldo OUT NUMBER                        --> Retorna valor do saldo
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE         --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2 ) is
    /* .............................................................................

    Programa: pc_ret_saldo_dia_prej
    Sistema :
    Sigla   : PREJ
    Autor   : Odirlei Busana - AMcom
    Data    : Maio/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retornar saldo do dia da conta transitória (créditos bloqueados por prejuízo)

    Alteracoes:

    ..............................................................................*/

    ---->> CURSORES <<-----
    --> Buscar saldo anterior
    CURSOR cr_crapsda( pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE,
                       pr_dtmvtolt IN DATE ) IS
     SELECT vlblqprj FROM (SELECT sda.vlblqprj
        FROM crapsda sda
       WHERE sda.cdcooper = pr_cdcooper
         AND sda.nrdconta = pr_nrdconta
         AND sda.dtmvtolt = pr_dtmvtolt
       ORDER BY dtmvtolt DESC)
     WHERE rownum = 1;

    ---->> VARIAVEIS <<-----
     vr_cdcritic    NUMBER(3);
     vr_dscritic    VARCHAR2(1000);
     vr_exc_erro    EXCEPTION;

     rw_crapdat     btch0001.cr_crapdat%ROWTYPE;
     vr_vldsaldo    NUMBER;
  BEGIN
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
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    IF pr_dtmvtolt = rw_crapdat.dtmvtolt THEN
      vr_vldsaldo  := PREJ0003.fn_sld_cta_prj(pr_cdcooper => pr_cdcooper,
                                              pr_nrdconta => pr_nrdconta,
                                              pr_exclbloq => pr_exclbloq);
    ELSE
      --> Buscar saldo anterior
      OPEN cr_crapsda( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_dtmvtolt => pr_dtmvtolt);
      FETCH cr_crapsda INTO vr_vldsaldo;

      IF cr_crapsda%NOTFOUND THEN
        CLOSE cr_crapsda;
        vr_vldsaldo := 0;

        vr_dscritic := 'Não há saldo para o dia ' || to_char(pr_dtmvtolt,'DD/MM/RRRR');

        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapsda;
      END IF;
    END IF;

    pr_vldsaldo := vr_vldsaldo;
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao obter o saldo: ' || SQLERRM;
  END pc_ret_saldo_dia_prej;
  --
  PROCEDURE pc_transf_cc_preju_fraude(pr_cdcooper   IN NUMBER             --> Cooperativa conectada
                                     ,pr_nrdconta   IN NUMBER             --> Número da conta
                                     ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2          --> Descrição da crítica
                                     ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2) is      --> Erros do processo

    /* .............................................................................
    Programa: pc_transf_cc_preju_fraude
    Sistema :
    Sigla   : PREJ
    Autor   : Heckmann - AMcom
    Data    : Julho/2018.                  Ultima atualizacao: 05/12/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Transferir a conta corrente para prejuízo por motivo de fraude

    Alteracoes: 05/12/2018 - Ajustado rotina para permitir transferir apenas contas com saldo negativo.
                             PRJ450 - Regulatorio(Odirlei/AMcom)

    ..............................................................................*/

    ----------->>> VARIAVEIS <<<--------
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    vr_desmsg  varchar2(1000);         --> Utilizada para informar se a transação funcionou ou não

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posição no XML

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nrdrowid ROWID;
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    vr_indsaldo BINARY_INTEGER;
    
    --Tipo da tabela de saldos
    vr_tab_saldo EXTR0001.typ_tab_saldos;
    --Tipo de tabela de erro
    vr_tab_erro GENE0001.typ_tab_erro;

    ---->> CURSORES <<-----

  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
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
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;

      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    --Limpar tabela erros e saldos
    vr_tab_erro.DELETE;
    vr_tab_saldo.DELETE;
    --Popular registro crapdat

    --> Verifica se possui saldo para fazer a operacao 
    EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => pr_cdcooper
                                ,pr_rw_crapdat => rw_crapdat
                                ,pr_cdagenci   => vr_cdagenci
                                ,pr_nrdcaixa   => vr_nrdcaixa
                                ,pr_cdoperad   => vr_cdoperad
                                ,pr_nrdconta   => pr_nrdconta
                                ,pr_vllimcre   => 0
                                ,pr_tipo_busca => 'A' --> tipo de busca(A-dtmvtoan)
                                ,pr_flgcrass   => FALSE
                                ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                ,pr_des_reto   => vr_dscritic
                                ,pr_tab_sald   => vr_tab_saldo
                                ,pr_tab_erro   => vr_tab_erro);
    --Se ocorreu erro
    IF vr_dscritic = 'NOK' THEN
      -- Tenta buscar o erro no vetor de erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta;
      ELSE
        -- Montar mensagem de critica 
        vr_cdcritic := 9998; --Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: 
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                      ' EXTR0001.pc_obtem_saldo_dia(2), conta: '||pr_nrdconta;
      END IF;
      --Levantar Excecao
      RAISE vr_exc_saida;
    ELSE
      vr_dscritic := NULL;
    END IF;
          
    --Verificar o saldo retornado
    IF vr_tab_saldo.Count = 0 THEN
      --Montar mensagem erro
      vr_cdcritic := 1072; --Nao foi possivel consultar o saldo para a operacao.
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      --Levantar Excecao
      RAISE vr_exc_saida;
    ELSE
      -- Posiciona no primeiro registro da tabela temporária
      vr_indsaldo := vr_tab_saldo.first;
      --Se o saldo nao for suficiente
      IF vr_tab_saldo(vr_indsaldo).vlsddisp >= 0 THEN
        vr_dscritic := 'Saldo de conta corrente deve ser negativo.';
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
    END IF;

    begin
      pr_des_erro := 'OK';
      vr_desmsg   := 'Transferido a conta corrente fraude para prejuízo';

      -- Realiza a transferência da CC para prejuízo
      pc_grava_prejuizo_cc(pr_cdcooper
                          ,pr_nrdconta
                          ,'F'
                          ,pr_cdcritic
                          ,pr_dscritic
                          ,pr_des_erro);


      if pr_des_erro = 'NOK' then
        vr_desmsg := pr_dscritic;
      end if;

      COMMIT;

    exception
    when others then

      pr_cdcritic := vr_cdcritic;
      vr_desmsg   := 'Erro ao transferir a conta corrente fraude para prejuízo! ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';

      rollback;
    end;


      -- PASSA OS DADOS PARA O XML RETORNO
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      -- CAMPOS
      -- Insere o campo para retorno a tela
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'vr_desmsg',
                               pr_tag_cont => vr_desmsg,
                               pr_des_erro => vr_dscritic);

    BEGIN
      --Grava log
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Transferido a conta corrente para prejuízo'
                          ,pr_dttransa => SYSDATE--pr_dtmvtolt
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                          ,pr_idseqttl => 1--pr_idseqttl
                          ,pr_nmdatela => 'PREJU'--pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END;

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
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  end pc_transf_cc_preju_fraude;
  --

  PROCEDURE pc_calc_juro_prejuizo_mensal (pr_cdcooper IN NUMBER
                                        , pr_cdcritic    OUT crapcri.cdcritic%TYPE
                                        , pr_dscritic    OUT crapcri.dscritic%TYPE) IS
  /* .............................................................................

   Programa: pc_calc_juro_prejuizo_mensal
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Mensal

   Objetivo  : Calcula juros remuneratórios para as contas corrente transferidas para prejuízo.

   Observacao:
   Alteracoes:
   ..............................................................................*/

     CURSOR cr_contas IS
     SELECT prj.rowid linha
          , prj.cdcooper
          , prj.nrdconta
          , prj.idprejuizo
          , prj.dtrefjur
          , prj.dtinclusao
          , prj.vlsdprej
          , prj.vljuprej
       FROM tbcc_prejuizo prj
      WHERE prj.cdcooper = pr_cdcooper
        AND prj.dtliquidacao IS NULL;
      rw_contas cr_contas%ROWTYPE;

      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

     vr_diarefju  number(2);
     vr_mesrefju  number(2);
     vr_anorefju  number(4);
     vr_vljuprej  tbcc_prejuizo.vljuprej%type;

     vr_cdcritic crapcri.cdcritic%TYPE;
     vr_dscritic crapcri.dscritic%TYPE;

     vr_tab_retorno LANC0001.typ_reg_retorno;
     vr_incrineg PLS_INTEGER;
     vr_nrseqdig craplcm.nrseqdig%TYPE;
  BEGIN
     -- Carrega o calendário de datas da cooperativa
     OPEN BTCH0001.cr_crapdat(pr_cdcooper);
     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     CLOSE BTCH0001.cr_crapdat;

     -- Percorre as contas em prejuízo da cooperativa
     FOR rw_contas IN cr_contas LOOP
        -- Executa o cálculo dos juros remuneratórios
        PREJ0003.pc_calc_juro_remuneratorio(pr_cdcooper => rw_contas.cdcooper,
                                            pr_ehmensal => true,
                                            pr_dtdpagto => rw_crapdat.dtultdia,
                                            pr_idprejuizo => rw_contas.idprejuizo,
                                            pr_vljpreju => vr_vljuprej,
                                            pr_diarefju => vr_diarefju,
                                            pr_mesrefju => vr_mesrefju,
                                            pr_anorefju => vr_anorefju,
                                            pr_des_reto => vr_dscritic);

        IF vr_dscritic <> 'OK' THEN
          ROLLBACK;
        ELSE
          UPDATE tbcc_prejuizo prj
             SET prj.dtrefjur   = rw_crapdat.dtultdia,
                 prj.nrdiarefju = vr_diarefju,
                 prj.nrmesrefju = vr_mesrefju,
                 prj.nranorefju = vr_anorefju,
                 prj.vljuprej   = prj.vljuprej + vr_vljuprej
           WHERE ROWID = rw_contas.linha;

           -- Gera valor do campo "nrseqdig" a partir da sequence (para não usar CRAPLOT)
           vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
                                '1;100;650011');

           -- Debita os juros remuneratórios na conta corrente
           LANC0001.pc_gerar_lancamento_conta( pr_cdagenci => 1
                                             , pr_cdbccxlt => 100
                                             , pr_nrdolote => 650011
                                             , pr_cdhistor => 2718 -- juros remunaratorio do prejuizo
                                             , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             , pr_nrdconta => rw_contas.nrdconta
                                             , pr_nrdctabb => rw_contas.nrdconta
                                             , pr_nrdctitg => GENE0002.FN_MASK(rw_contas.nrdconta, '99999999')
                                             , pr_nrdocmto => 99992718
                                             , pr_vllanmto => vr_vljuprej
                                             , pr_nrseqdig => vr_nrseqdig
                                             , pr_cdcooper => pr_cdcooper
                                             , pr_tab_retorno => vr_tab_retorno
                                             , pr_incrineg => vr_incrineg
                                             , pr_cdcritic => vr_cdcritic
                                             , pr_dscritic => vr_dscritic);

          COMMIT;
        END IF;
     END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro calc. Juro prejuízo mensal: ' || SQLERRM;
  END pc_calc_juro_prejuizo_mensal;

  PROCEDURE pc_calc_juro_remuneratorio (pr_cdcooper    IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                       ,pr_ehmensal    IN BOOLEAN --Indicador Mensal
                                       ,pr_dtdpagto    IN crapdat.dtmvtolt%TYPE --Data pagamento
                                       ,pr_idprejuizo  IN NUMBER -- indicador do prejuizo a ser calculado
                                       ,pr_vljpreju    OUT NUMBER --Valor Juros no Mes
                                       ,pr_diarefju    OUT INTEGER --Dia Referencia Juros
                                       ,pr_mesrefju    OUT INTEGER --Mes Referencia Juros
                                       ,pr_anorefju    OUT INTEGER --Ano Referencia Juros
                                       ,pr_des_reto    OUT VARCHAR2 --Retorno OK/NOK
                                       ) IS
    /* .............................................................................
    Programa: pc_calc_juro_remuneratorio
    Sistema :
    Sigla   : PREJ
    Autor   : Renato Cordeiro - AMcom
    Data    : Julho/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Calcular juros remuneratórios para conta corrente em prejuízo

    Alteracoes:
    ..............................................................................*/
       vr_exc_saida EXCEPTION;

       -- Recupera as informações do prejuízo de conta corrente
       CURSOR cr_prejuizo IS
       SELECT prj.dtinclusao
            , prj.dtrefjur
                        , prj.nrdiarefju
                        , prj.nrmesrefju
                        , prj.nranorefju
            , (prj.vlsdprej +
              prj.vljur60_ctneg +
              prj.vljur60_lcred +
              prj.vljuprej) vlsdtotal
         FROM tbcc_prejuizo prj
        WHERE prj.idprejuizo = pr_idprejuizo;
       rw_prejuizo cr_prejuizo%ROWTYPE;

       vr_dstextab craptab.dstextab%TYPE;
       vr_pctaxpre NUMBER := 0;

       vr_diarefju  tbcc_prejuizo.nrdiarefju%TYPE;
       vr_dtdpagto  number(8);
       vr_mesrefju  tbcc_prejuizo.nrmesrefju%TYPE;
       vr_anorefju  tbcc_prejuizo.nranorefju%TYPE;
       vr_diafinal  tbcc_prejuizo.nrdiarefju%TYPE;
       vr_mesfinal  tbcc_prejuizo.nrmesrefju%TYPE;
       vr_anofinal  tbcc_prejuizo.nranorefju%TYPE;
       vr_qtdedias  tbcc_prejuizo.qtdiaatr%TYPE;

       vr_potencia NUMBER(30, 10);
       vr_valor    NUMBER;
  BEGIN
     pr_des_reto := 'OK';

     OPEN cr_prejuizo;
         FETCH cr_prejuizo INTO rw_prejuizo;

     IF cr_prejuizo%NOTFOUND THEN
        pr_des_reto := 'Não há prejuízo ativo para a conta informada: ' || pr_idprejuizo;

        CLOSE cr_prejuizo;

        RAISE vr_exc_saida;
     END IF;

     CLOSE cr_prejuizo;

     vr_dtdpagto := to_char(pr_dtdpagto,'DD');

     IF nvl(rw_prejuizo.nrdiarefju, 0) <> 0 AND
              nvl(rw_prejuizo.nrmesrefju, 0) <> 0 AND
                nvl(rw_prejuizo.nranorefju, 0) <> 0 THEN
        vr_diarefju := rw_prejuizo.nrdiarefju;
        vr_mesrefju := rw_prejuizo.nrmesrefju;
        vr_anorefju := rw_prejuizo.nranorefju;
     else
        vr_diarefju := to_char(rw_prejuizo.dtinclusao,'DD');
        vr_mesrefju := to_char(rw_prejuizo.dtinclusao,'MM');
        vr_anorefju := to_char(rw_prejuizo.dtinclusao,'RRRR');
     end if;

     vr_diafinal := to_char(pr_dtdpagto,'DD');
     vr_mesfinal := to_char(pr_dtdpagto,'MM');
     vr_anofinal := to_char(pr_dtdpagto,'RRRR');

     -- Calcula a quantidade de dias a ser considerada para o cálculo dos juros remuneratórios
     empr0001.pc_calc_dias360(pr_ehmensal => pr_ehmensal,
                              pr_dtdpagto => vr_dtdpagto,
                              pr_diarefju => vr_diarefju,
                              pr_mesrefju => vr_mesrefju,
                              pr_anorefju => vr_anorefju,
                              pr_diafinal => vr_diafinal,
                              pr_mesfinal => vr_mesfinal,
                              pr_anofinal => vr_anofinal,
                              pr_qtdedias => vr_qtdedias);

     -- Buscar dados da TAB para extração da taxa de juros remuneratórios
     vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'PAREMPREST'
                                              ,pr_tpregist => 01);

     -- Extrai a taxa de juros remuneratórios cadastrada na tela TAB089
     vr_pctaxpre := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,121,6)),0);

     --Calcular Juros
     vr_valor    := 1 + (vr_pctaxpre / 100);
     vr_potencia := POWER(vr_valor, vr_qtdedias);

     --Retornar Juros calculados
     pr_vljpreju := rw_prejuizo.vlsdtotal * (vr_potencia - 1);

     --Se valor for  negativo
     IF pr_vljpreju < 0 THEN
        --zerar Valor
        pr_vljpreju := 0;
        --Sair
        RAISE vr_exc_saida;
     END IF;

     pr_diarefju := vr_diafinal;
     pr_mesrefju := vr_mesfinal;
     pr_anorefju := vr_anofinal;
     pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_reto := 'NOK';
  END pc_calc_juro_remuneratorio;

 PROCEDURE pc_calc_juros_remun_prov(pr_cdcooper IN tbcc_prejuizo.cdcooper%TYPE
                                  , pr_nrdconta IN tbcc_prejuizo.nrdconta%TYPE
                                  , pr_vljuprov OUT tbcc_prejuizo.vljuprej%TYPE
                                  , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  , pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* .............................................................................

   Programa: pc_calc_juros_remun_prov
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Mensal

   Objetivo  : Calcula juros remuneratórios provisionado para uma conta corrente transferida para prejuízo.

   Observacao:
   Alteracoes:
   ..............................................................................*/

   -- CURSORES --
    CURSOR cr_tbcc_prejuizo(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                            pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
      SELECT prej.nrdiarefju
           , prej.nrmesrefju
           , prej.nranorefju
           , prej.idprejuizo
           , prej.dtinclusao
        FROM tbcc_prejuizo prej
       WHERE prej.cdcooper = pr_cdcooper
         AND prej.nrdconta = pr_nrdconta
         AND prej.dtliquidacao IS NULL;
    rw_tbcc_prejuizo cr_tbcc_prejuizo%ROWTYPE;

   vr_vljupre_prov NUMBER;
   vr_diarefju  number(2);
   vr_mesrefju  number(2);
   vr_anorefju  number(4);

   vr_cdcritic crapcri.cdcritic%TYPE;
   vr_dscritic crapcri.dscritic%TYPE;
   vr_exc_saida EXCEPTION;

   rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
 BEGIN
   pr_cdcritic := 0;
   pr_dscritic := NULL;

   OPEN BTCH0001.cr_crapdat(pr_cdcooper);
   FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
   CLOSE BTCH0001.cr_crapdat;

   OPEN cr_tbcc_prejuizo(pr_cdcooper => pr_cdcooper
                       , pr_nrdconta => pr_nrdconta);
   FETCH cr_tbcc_prejuizo INTO rw_tbcc_prejuizo;

   IF cr_tbcc_prejuizo%NOTFOUND THEN
     vr_cdcritic := 0;
     vr_dscritic := 'A conta informada não se encontra em prejuízo.';

     CLOSE cr_tbcc_prejuizo;

     RAISE vr_exc_saida;
   END IF;

   CLOSE cr_tbcc_prejuizo;

   -- Calcula os juros remuneratórios desde a última data de pagamento/débito até o dia atual
    vr_diarefju  := nvl(rw_tbcc_prejuizo.nrdiarefju, to_char(rw_tbcc_prejuizo.dtinclusao, 'DD'));
    vr_mesrefju  := nvl(rw_tbcc_prejuizo.nrmesrefju, to_char(rw_tbcc_prejuizo.dtinclusao, 'MM'));
    vr_anorefju  := nvl(rw_tbcc_prejuizo.nranorefju, to_char(rw_tbcc_prejuizo.dtinclusao, 'YYYY'));

    PREJ0003.pc_calc_juro_remuneratorio(pr_cdcooper => pr_cdcooper,
                                        pr_ehmensal => FALSE,
                                        pr_dtdpagto => rw_crapdat.dtmvtolt,
                                        pr_idprejuizo => rw_tbcc_prejuizo.idprejuizo,
                                        pr_vljpreju => vr_vljupre_prov,
                                        pr_diarefju => vr_diarefju,
                                        pr_mesrefju => vr_mesrefju,
                                        pr_anorefju => vr_anorefju,
                                        pr_des_reto => vr_dscritic);

    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic <> NULL THEN
      RAISE vr_exc_saida;
    END IF;

    pr_vljuprov := vr_vljupre_prov;
 EXCEPTION
   WHEN vr_exc_saida THEN
     pr_dscritic := vr_dscritic;
     pr_dscritic := vr_dscritic;
   WHEN OTHERS THEN
     pr_cdcritic := 0;
     pr_dscritic := 'Erro não tratado na rotina PREJ0003.pc_calc_juros_remun_prov: ' || SQLERRM;
 END pc_calc_juros_remun_prov; 

 PROCEDURE pc_pagar_prejuizo_cc(pr_cdcooper IN crapass.cdcooper%TYPE
                              , pr_nrdconta IN crapass.nrdconta%TYPE
                              , pr_vlrpagto IN craplcm.vllanmto%TYPE
                              , pr_vlrabono IN craplcm.vllanmto%TYPE DEFAULT NULL
                                                            , pr_atsldlib IN INTEGER DEFAULT 1 -- se deve atualizar o saldo liberado para operações na conta corrente
                              , pr_cdcritic OUT crapcri.cdcritic%TYPE
                              , pr_dscritic OUT crapcri.dscritic%TYPE) IS
   /* .............................................................................

  Programa: pc_pagar_prejuizo_cc
  Sistema : AYLLOS
  Sigla   : PREJ
  Autor   : Reginaldo (AMcom)
  Data    : Agosto/2018.                  Ultima atualizacao: 24/04/2019

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo : Efetua a o pagamento de prejuízo de uma conta específica.

  Alteracoes: 24/04/2019 - P450 - Refatoração do código da procedure e inclusão de SAVEPOINT para garantir atomicidade da transação de 
                           pagamento (paga tudo, ou não paga nada). (Reginaldo/AMcom)
   ..............................................................................*/
  --

  -- Retorna as contas em prejuizo
  CURSOR cr_contaprej (pr_cdcooper  IN tbcc_prejuizo.cdcooper%TYPE
                     , pr_nrdconta  IN tbcc_prejuizo.nrdconta%TYPE) IS
    SELECT tbprj.vlsdprej,
           tbprj.vljuprej,
           tbprj.vlpgprej,
           tbprj.vljur60_ctneg,
           tbprj.vljur60_lcred,
           tbprj.dtrefjur,
           tbprj.nrdiarefju,
           tbprj.nrmesrefju,
           tbprj.nranorefju,
                     tbprj.dtinclusao,
           tbprj.rowid,
           tbprj.idprejuizo
      FROM tbcc_prejuizo tbprj
     WHERE tbprj.cdcooper = pr_cdcooper
       AND tbprj.nrdconta = pr_nrdconta
       AND tbprj.dtliquidacao IS NULL;
   rw_contaprej cr_contaprej%ROWTYPE;

  -- Verifica valor de IOF do saldo da conta
  CURSOR cr_crapsldiof (pr_cdcooper crapsld.cdcooper%TYPE,
                        pr_nrdconta crapsld.nrdconta%TYPE ) IS
   SELECT sld.vliofmes,
          sld.vlbasiof,
          sld.rowid
     FROM crapsld sld
    WHERE sld.cdcooper = pr_cdcooper
      AND sld.nrdconta = pr_nrdconta;
   rw_crapsldiof cr_crapsldiof%ROWTYPE;

  --Verifica se tem lançamento futuro para IOF
  CURSOR cr_craplauiof (pr_cdcooper crapsld.cdcooper%TYPE,
                        pr_nrdconta crapsld.nrdconta%TYPE ) IS

   SELECT vllanaut vliofmes,
          0 vlbasiof,
          idlancto,
          ROWID
     FROM craplau lau
    WHERE lau.cdcooper = pr_cdcooper
      AND lau.nrdconta = pr_nrdconta
      AND lau.cdhistor = 2323
      AND lau.insitlau = 1;
  rw_craplauiof  cr_craplauiof%ROWTYPE;

  rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

  vr_vlsddisp  NUMBER := 0;
  vr_valrpago  NUMBER := 0;
  vr_vllanciof NUMBER := 0;
    vr_vliofpag  NUMBER := 0;

  vr_tab_retorno LANC0001.typ_reg_retorno; -- Record com dados retornados pela "pc_gerar_lancamento_conta"
  vr_incrineg   PLS_INTEGER;

  vr_vljr60_ctneg  tbcc_prejuizo.vljur60_ctneg%TYPE  := 0; -- Valor pago de juros +60 (hist. 37 + hist. 57)
  vr_vljur60_lcred tbcc_prejuizo.vljur60_lcred%TYPE  := 0; -- Valor pago de juros +60 (hist. 38)
  vr_vljupre       tbcc_prejuizo.vljuprej%TYPE       := 0; -- Valor pago de juros remuneratórios do prejuízo
  vr_vljupre_prov  NUMBER                            := 0; -- Valor pago de juros remuneratórios (provisionados) do prejuízo
  vr_vlprinc       tbcc_prejuizo.vlsdprej%TYPE       := 0; -- Valor pago do saldo devedor principal do prejuízo
  vr_nrseqdig      craplcm.nrseqdig%TYPE;
  vr_nrdocmto      craplcm.nrdocmto%TYPE;

  vr_diarefju  number(2);
  vr_mesrefju  number(2);
  vr_anorefju  number(4);

  vr_des_erro VARCHAR2(2000);

    vr_exc_saida EXCEPTION;
    
    vr_dthrtran DATE := SYSDATE; -- Data/hora da transação para armazenar nos lanctos da TBCC_PREJUIZO_DETALHE
 BEGIN
    pr_cdcritic := 0;
    pr_dscritic := NULL;

    -- Compõe o saldo disponível para pagamento com a soma do valor pago e do valor do abono concedido
    vr_vlsddisp := pr_vlrpagto + nvl(pr_vlrabono, 0);

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;

      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Recupera informações do prejuízo da conta
    OPEN cr_contaprej(pr_cdcooper, pr_nrdconta);
    FETCH cr_contaprej INTO rw_contaprej;
    CLOSE cr_contaprej;

     vr_vljr60_ctneg  := 0;
     vr_vljur60_lcred := 0;
     vr_vljupre       := 0;

     SAVEPOINT savtrans_pagamento_prejuizo;

     -- Verifica IOF provisionado no saldo da conta
     OPEN cr_crapsldiof(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta);
     FETCH cr_crapsldiof INTO rw_crapsldiof;
     CLOSE cr_crapsldiof;

    -- Conta possui saldo
    IF vr_vlsddisp > 0 AND rw_crapsldiof.vliofmes > 0 THEN
      IF vr_vlsddisp  >= rw_crapsldiof.vliofmes THEN
         vr_vllanciof := rw_crapsldiof.vliofmes;     -- Paga Total
      ELSE
         vr_vllanciof := vr_vlsddisp;  --Paga Parcial
      END IF;

      pc_pagar_IOF_conta_prej(pr_cdcooper   => pr_cdcooper           -- Código da Cooperativa
                             ,pr_nrdconta   => pr_nrdconta -- Número da Conta
                             ,pr_vllanmto   => vr_vllanciof          -- Valor do Lançamento
                             ,pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_vlbasiof   => rw_crapsldiof.vlbasiof
                             ,pr_cdcritic   => vr_cdcritic           -- Código de críticia
                             ,pr_dscritic   => vr_dscritic );

        -- Se retornou erro
       IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
       END IF;

       -- Incluir lançamento na TBCC_PREJUIZO_DETALHE
       -- IOF (Hist 2323)
       pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2323
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => vr_vllanciof
                              , pr_dthrtran => vr_dthrtran
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

       -- Zera o valor do IOF provisionado na CRAPSLD
       UPDATE crapsld sld
          SET vliofmes = vliofmes - vr_vllanciof
            , vlbasiof = 0
        WHERE ROWID = rw_crapsldiof.rowid;
    END IF;

    --Calcula o saldo disponivel  apos pagamento de IOF
    vr_vlsddisp := vr_vlsddisp - nvl(vr_vllanciof,0);
    vr_valrpago := vr_valrpago + nvl(vr_vllanciof,0);
        vr_vliofpag := vr_vliofpag + nvl(vr_vllanciof,0);

    vr_vllanciof := 0; -- Reinicializa a variável para reutilizá-la

    -- Verifica IOF no saldo da conta CRAPLAU (lançamentos furutos)
    OPEN cr_craplauiof(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
    FETCH cr_craplauiof INTO rw_craplauiof;
    CLOSE cr_craplauiof;

    -- Conta possui saldo
    IF vr_vlsddisp > 0 AND nvl(rw_craplauiof.vliofmes,0) > 0 THEN
      IF vr_vlsddisp  >= rw_craplauiof.vliofmes THEN
         vr_vllanciof := rw_craplauiof.vliofmes;     -- Paga Total
      ELSE
        vr_vllanciof := vr_vlsddisp;  --Paga Parcial
      END IF;

      pc_pagar_IOF_conta_prej(pr_cdcooper   => pr_cdcooper           -- Código da Cooperativa
                             ,pr_nrdconta   => pr_nrdconta           -- Número da Conta
                             ,pr_vllanmto   => vr_vllanciof          -- Valor do Lançamento
                             ,pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_vlbasiof   => rw_craplauiof.vlbasiof
                             ,pr_idlautom   => rw_craplauiof.idlancto
                             ,pr_cdcritic   => vr_cdcritic           -- Código de críticia
                             ,pr_dscritic   => vr_dscritic );

        -- Se retornou erro
       IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
       END IF;

       -- Incluir lançamento na TBCC_PREJUIZO_DETALHE
       -- IOF (Hist 2323)
       pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2323
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => vr_vllanciof
                              , pr_dthrtran => vr_dthrtran
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

       -- Marca o lançamento como "Efetivado"
       UPDATE craplau
          SET insitlau = 2
        WHERE ROWID = rw_craplauiof.rowid;
    END IF;

    --Calcula o saldo disponivel  apos pagamento de IOF
    vr_vlsddisp := vr_vlsddisp - nvl(vr_vllanciof,0);
    vr_valrpago := vr_valrpago + nvl(vr_vllanciof,0);
        vr_vliofpag := vr_vliofpag + nvl(vr_vllanciof,0);

    IF vr_vlsddisp > 0 AND rw_contaprej.vljur60_ctneg > 0 THEN
       --O Saldo disponivel pode liquidar Juros60 37,57
       IF vr_vlsddisp >= rw_contaprej.vljur60_ctneg THEN
         vr_vljr60_ctneg := rw_contaprej.vljur60_ctneg;
       ELSE
         vr_vljr60_ctneg := vr_vlsddisp;
       END IF;
    END IF;

    vr_vlsddisp:= vr_vlsddisp - vr_vljr60_ctneg;
    vr_valrpago := vr_valrpago + vr_vljr60_ctneg;

    IF  vr_vlsddisp > 0 AND rw_contaprej.vljur60_lcred > 0 THEN
       --O Saldo disponivel pode liquidar Juros60 38
       IF vr_vlsddisp >= rw_contaprej.vljur60_lcred THEN
         vr_vljur60_lcred := rw_contaprej.vljur60_lcred;
       ELSE
         vr_vljur60_lcred := vr_vlsddisp;
       END IF;
    END IF;

    vr_vlsddisp := vr_vlsddisp - vr_vljur60_lcred;
    vr_valrpago := vr_valrpago + vr_vljur60_lcred;

    IF vr_vljr60_ctneg + vr_vljur60_lcred > 0 THEN
       -- Incluir lançamento na TBCC_PREJUIZO_DETALHE
       -- Juros +60 (Hist 37 + Hist 57)
       pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2727
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => vr_vljr60_ctneg + vr_vljur60_lcred
                              , pr_dthrtran => vr_dthrtran
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);
    END IF;

    IF  vr_vlsddisp > 0 AND rw_contaprej.vljuprej > 0 THEN
       IF vr_vlsddisp >= rw_contaprej.vljuprej THEN
          vr_vljupre :=  rw_contaprej.vljuprej;
       ELSE
          vr_vljupre :=  vr_vlsddisp;
       END IF;
    END IF;

    vr_vlsddisp := vr_vlsddisp - vr_vljupre;
    vr_valrpago := vr_valrpago + vr_vljupre;

    IF vr_vlsddisp > 0 THEN
      -- Calcula os juros remuneratórios desde a última data de pagamento/débito até o dia atual
      vr_diarefju  := nvl(rw_contaprej.nrdiarefju, to_char(rw_contaprej.dtinclusao, 'DD'));
      vr_mesrefju  := nvl(rw_contaprej.nrmesrefju, to_char(rw_contaprej.dtinclusao, 'MM'));
      vr_anorefju  := nvl(rw_contaprej.nranorefju, to_char(rw_contaprej.dtinclusao, 'YYYY'));

      PREJ0003.pc_calc_juro_remuneratorio(pr_cdcooper => pr_cdcooper,
                                                         pr_ehmensal => FALSE,
                                                         pr_dtdpagto => rw_crapdat.dtmvtolt,
                                                         pr_idprejuizo => rw_contaprej.idprejuizo,
                                                         pr_vljpreju => vr_vljupre_prov,
                                                         pr_diarefju => vr_diarefju,
                                                         pr_mesrefju => vr_mesrefju,
                                                         pr_anorefju => vr_anorefju,
                                                         pr_des_reto => vr_dscritic);

      IF vr_vljupre_prov > 0 THEN
        -- Atualiza juros remuneratórios do prejuízo
        UPDATE tbcc_prejuizo prj
           SET prj.dtrefjur = rw_crapdat.dtmvtolt
             , prj.nrdiarefju = vr_diarefju
             , prj.nrmesrefju = vr_mesrefju
             , prj.nranorefju = vr_anorefju
             , prj.vljuprej   = prj.vljuprej + vr_vljupre_prov
           WHERE prj.idprejuizo = rw_contaprej.idprejuizo;

        -- Gera valor do campo "nrseqdig" a partir da sequence (para não usar CRAPLOT)
        vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
                                '1;100;650011');

        -- Debita os juros remuneratórios na conta corrente
        LANC0001.pc_gerar_lancamento_conta( pr_cdagenci => 1
                                           , pr_cdbccxlt => 100
                                           , pr_nrdolote => 650011
                                           , pr_cdhistor => 2718 -- juros remunaratorio do prejuizo
                                           , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           , pr_nrdconta => pr_nrdconta
                                           , pr_nrdctabb => pr_nrdconta
                                           , pr_nrdctitg => GENE0002.FN_MASK(pr_nrdconta, '99999999')
                                           , pr_nrdocmto => fn_gera_nrdocmto_craplcm(pr_cdcooper => pr_cdcooper
                                                                                   , pr_nrdconta => pr_nrdconta
                                                                                   , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                                                   , pr_cdhistor => 2718)
                                           , pr_vllanmto => vr_vljupre_prov
                                           , pr_nrseqdig => vr_nrseqdig
                                           , pr_cdcooper => pr_cdcooper
                                           , pr_tab_retorno => vr_tab_retorno
                                           , pr_incrineg => vr_incrineg
                                           , pr_cdcritic => vr_cdcritic
                                           , pr_dscritic => vr_dscritic
                                           );
                                                                    
              -- Lança juros remuneratórios no extrato
        pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                               , pr_nrdconta => pr_nrdconta
                               , pr_dtmvtolt => rw_crapdat.dtmvtolt
                               , pr_cdhistor => 2718
                               , pr_idprejuizo => rw_contaprej.idprejuizo
                               , pr_vllanmto => vr_vljupre_prov
                               , pr_dthrtran => vr_dthrtran
                               , pr_cdcritic => vr_cdcritic
                               , pr_dscritic => vr_dscritic);

        -- Verifica se pode pagar o valor total ou parcial dos juros
        IF vr_vlsddisp < vr_vljupre_prov THEN
          vr_vljupre_prov := vr_vlsddisp;
        END IF;

        -- Atualiza o valor dos juros remuneratórios, descontando o valor pago
        UPDATE  TBCC_PREJUIZO tbprj
          SET   tbprj.vljuprej = tbprj.vljuprej - vr_vljupre_prov
          WHERE tbprj.rowid = rw_contaprej.rowid;
      END IF;
    END IF;

    IF vr_vljupre_prov + vr_vljupre > 0 THEN
       -- Incluir lançamento na TBCC_PREJUIZO_DETALHE
       -- Juros remuneratórios (Hist 2729)
       pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2729
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => vr_vljupre_prov + vr_vljupre
                              , pr_dthrtran => vr_dthrtran
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);
    END IF;

    vr_vlsddisp := vr_vlsddisp - vr_vljupre_prov;
    vr_valrpago := vr_valrpago + vr_vljupre_prov;

        IF vr_vljr60_ctneg > 0 THEN
           BEGIN
          UPDATE TBCC_PREJUIZO tbprj
          SET tbprj.vljur60_ctneg = tbprj.vljur60_ctneg - vr_vljr60_ctneg
          WHERE tbprj.rowid = rw_contaprej.rowid;
        EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic:=0;
           vr_dscritic := 'Erro ao atualizar Juros60 - TBCC_PREJUIZO:'||SQLERRM;
         RAISE vr_exc_saida;
       END;
        END IF;

        IF vr_vljur60_lcred > 0 THEN
            BEGIN
          UPDATE  TBCC_PREJUIZO tbprj
          SET tbprj.vljur60_lcred = tbprj.vljur60_lcred - vr_vljur60_lcred
          WHERE tbprj.rowid = rw_contaprej.rowid;
       EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic:=0;
             vr_dscritic := 'Erro ao atualizar Juros60 - TBCC_PREJUIZO:'||SQLERRM;
           RAISE vr_exc_saida;
       END;
        END IF;

        IF vr_vljupre > 0 THEN
            BEGIN
                UPDATE  TBCC_PREJUIZO tbprj
                SET   tbprj.vljuprej = tbprj.vljuprej - vr_vljupre
                WHERE tbprj.rowid = rw_contaprej.rowid;
            EXCEPTION
                 WHEN OTHERS THEN
                     vr_cdcritic:= 0;
                     vr_dscritic := 'Erro ao atualizar valor de Juros Remuneratórios - TBCC_PREJUIZO:'||SQLERRM;
                 RAISE vr_exc_saida;
            END;
        END IF;

    -- Pagar saldo do prejuízo
    IF vr_vlsddisp > 0 THEN
      IF vr_vlsddisp >= rw_contaprej.vlsdprej THEN
        vr_vlprinc := rw_contaprej.vlsdprej;
      ELSE
        vr_vlprinc := vr_vlsddisp;
      END IF;

      IF nvl(vr_vlprinc,0) <> 0 THEN

      -- Valor pago do saldo devedor principal do prejuízo
      pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                             , pr_nrdconta => pr_nrdconta
                             , pr_dtmvtolt => rw_crapdat.dtmvtolt
                             , pr_cdhistor => 2725
                             , pr_idprejuizo => rw_contaprej.idprejuizo
                             , pr_vllanmto => vr_vlprinc
                             , pr_dthrtran => vr_dthrtran
                             , pr_cdcritic => vr_cdcritic
                             , pr_dscritic => vr_dscritic);

      -- Atualiza o saldo devedor, descontando o valor pago
      UPDATE tbcc_prejuizo prj
         SET prj.vlsdprej = prj.vlsdprej - vr_vlprinc
       WHERE prj.rowid = rw_contaprej.rowid;
         
    END IF;
    END IF;

    vr_valrpago := vr_valrpago + vr_vlprinc;

    -- Lançar valor do abono no extrato do prejuízo
    IF nvl(pr_vlrabono, 0) > 0 THEN
      
      -- Valor do abono concedido no pagamento
      pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2723
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => pr_vlrabono
                              , pr_dthrtran => vr_dthrtran
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

      -- Gera valor do campo "nrseqdig" a partir da sequence (para não usar CRAPLOT)
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') ||';'||
                                '1;100;650010');

      -- Efetua lancamento de crédito na CRAPLCM(LANC0001)
      LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdagenci => 1
                                        ,pr_cdbccxlt => 100
                                        ,pr_nrdolote => 650010
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdocmto => fn_gera_nrdocmto_craplcm(pr_cdcooper => pr_cdcooper
                                                                               , pr_nrdconta => pr_nrdconta
                                                                               , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                                               , pr_cdhistor => 2723)
                                        ,pr_cdoperad => '1'
                                        ,pr_nrdctabb => pr_nrdconta
                                        ,pr_nrseqdig => vr_nrseqdig
                                        ,pr_dtrefere => rw_crapdat.dtmvtolt
                                        ,pr_vllanmto => pr_vlrabono
                                        ,pr_cdhistor => 2723
                                        -- OUTPUT --
                                        ,pr_tab_retorno => vr_tab_retorno
                                        ,pr_incrineg => vr_incrineg
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao creditar o abono do prejuízo na conta corrente.';

          RAISE vr_exc_saida;
        END IF;


      UPDATE tbcc_prejuizo
         SET vlrabono = nvl(vlrabono, 0) + pr_vlrabono
       WHERE ROWID = rw_contaprej.rowid;
    END IF;

    IF pr_vlrpagto > 0 AND pr_vlrpagto > vr_vliofpag THEN
      -- Lança débito referente ao pagamento do prejuízo
      pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2721
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => pr_vlrpagto - nvl(vr_vliofpag,0)
                              , pr_dthrtran => vr_dthrtran
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

      -- Lança crédito referente ao pagamento do prejuízo
      pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2733
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => pr_vlrpagto - nvl(vr_vliofpag,0)
                              , pr_dthrtran => vr_dthrtran
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);
    END IF;

    UPDATE tbcc_prejuizo
       SET vlpgprej = nvl(vlpgprej, 0) + least(vr_valrpago, pr_vlrpagto)
     WHERE ROWID = rw_contaprej.rowid;

    IF pr_atsldlib = 1 THEN
            -- Desconta o valor total do pagamento efetuado do saldo disponível para operações na C/C
            pc_atualiza_sld_lib_prj(pr_cdcooper => pr_cdcooper
                                                        , pr_nrdconta => pr_nrdconta
                                                        , pr_vlrdebto => least(vr_valrpago, pr_vlrpagto)
                                                        , pr_cdcritic => vr_cdcritic
                                                        , pr_dscritic => vr_dscritic
                                                        , pr_des_erro => vr_des_erro);
        END IF;

 EXCEPTION
     WHEN vr_exc_saida THEN
         pr_cdcritic := 0;
         pr_dscritic := vr_dscritic;
     
     ROLLBACK TO SAVEPOINT savtrans_pagamento_prejuizo;
   WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 99999;
      pr_dscritic := 'Erro não tratado na rotina PREJ0003.pc_pagar_prejuizo_cc: ' ||SQLERRM;
     
     ROLLBACK TO SAVEPOINT savtrans_pagamento_prejuizo;
 END pc_pagar_prejuizo_cc;

 PROCEDURE pc_pagar_prejuizo_cc_autom(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
/* .............................................................................

Programa: pc_pagar_prejuizo_cc_autom
Sistema :
Sigla   : PREJ
Autor   : Rangel Decker  AMcom
Data    : Junho/2018.                  Ultima atualizacao:

Dados referentes ao programa:

Frequencia: Diária (sempre que chamada)

Objetivo  : Efetua a o pagamento de prejuízo de forma automática.


Alteracoes: 29/11/2018 - Ajustado rotina para realizar pagamento apenas se ainda existir saldo de prejuizo
                         PRJ450 - Regulatorio(Odirlei/AMcom)
              
            08/02/2019 - Inclusão de tratamento específico para o histórico 1017 se a cooperativa for Transpocred.
                         Se houver lançamentos do histórico 1017 cuja soma coincida com o valor liberado da conta 
                         transitória, não efetua o pagamento e deixa o crédito na conta corrente.
                         P450 - Reginaldo/AMcom

            11/02/2019 - Ajuste para correção de pagamento de valor maior que o saldo devedor do prejuízo.
                         P450 - Reginaldo/AMcom
                         
            24/04/2019 - Alteração para considerar saldo disponível (créditos) na conta corrente ao invés do campo VLSLDLIB
                         P450 - Reginaldo/AMcom

            15/05/2019 - P450 - Tratamento historico 2733 (Reginaldo/AMcom)

 ..............................................................................*/
--

    -- Retorna as contas em prejuizo
    CURSOR cr_contaprej (pr_cdooper  IN tbcc_prejuizo.cdcooper%TYPE) IS
      SELECT tbprj.idprejuizo,
             tbprj.cdcooper,
             tbprj.nrdconta,
             tbprj.dtinclusao,
             tbprj.qtdiaatr,
             tbprj.vlsdprej,
             tbprj.vljuprej,
             tbprj.vlpgprej,
             tbprj.vlrabono,
             tbprj.vljur60_ctneg,
             tbprj.vljur60_lcred,
             tbprj.dtrefjur,
             tbprj.nrdiarefju,
             tbprj.nrmesrefju,
             tbprj.nranorefju
        FROM tbcc_prejuizo tbprj
       WHERE tbprj.cdcooper = pr_cdcooper
         AND tbprj.dtliquidacao IS NULL;
     rw_contaprej cr_contaprej%ROWTYPE;

     -- Busca lançamentos do histórico 1017 (somente para coop. Transpocred)
     CURSOR cr_hist1017(pr_nrdconta craplcm.nrdconta%TYPE
                      , pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS 
     SELECT nvl(SUM(lcm.vllanmto),0) vltotlan
       FROM craplcm lcm
      WHERE lcm.cdcooper = 9 -- Somente Transpocred
        AND lcm.nrdconta = pr_nrdconta
        AND lcm.cdhistor = 1017
        AND lcm.dtmvtolt = pr_dtmvtolt;


     CURSOR cr_hist2733(pr_cdcooper craplcm.cdcooper%TYPE
                      , pr_nrdconta craplcm.nrdconta%TYPE
                      , pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS
     SELECT nvl(SUM(prj.vllanmto), 0) vltotlan
       FROM tbcc_prejuizo_detalhe prj
      WHERE prj.cdcooper = pr_cdcooper
        AND prj.nrdconta = pr_nrdconta
        AND prj.dtmvtolt = pr_dtmvtolt
        AND prj.cdhistor = 2733;

     vr_cdcritic  NUMBER(3);
     vr_dscritic  VARCHAR2(1000);
     vr_des_erro  VARCHAR2(1000);

     vr_exc_saida exception;

     vr_vlsddisp NUMBER;
     vr_vlsldprj NUMBER;

     vr_vldeb1017 NUMBER := 0; -- Valor dos débitos do histórico 1017 (Aplicável somente para a Transpocred)
     vr_vllan2733 NUMBER := 0; -- Valor da soma dos lançamentos com histórico 2733 ocorridos no dia

     rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  BEGIN
       OPEN BTCH0001.cr_crapdat(pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       CLOSE BTCH0001.cr_crapdat;

       -- Percorre a lista de contas em prejuízo
       FOR  rw_contaprej in cr_contaprej(pr_cdooper => pr_cdcooper) LOOP
         -- Obtém saldo disponível na conta corrente para pagamento do prejuízo
         vr_vlsddisp:= PREJ0006.fn_obtem_saldo_lcm_dia(pr_cdcooper => pr_cdcooper
                                                     , pr_nrdconta => rw_contaprej.nrdconta
                                                     , pr_dtmvtolt => rw_crapdat.dtmvtolt);
                       
         -- Se não há valor disponível na conta corrente, não há como efetuar o pagamento                              
         IF vr_vlsddisp <= 0 THEN
           PREJ0006.pc_zera_saldo_liberado_CT(pr_cdcooper => pr_cdcooper
                                              , pr_nrdconta => rw_contaprej.nrdconta);
                                              
           CONTINUE;
         END IF;
         

         -- Verificar se já houve lancamento para 2733 durante o dia (Online)
         -- Se já houve, desconta do valor disponivel na Conta.
         OPEN cr_hist2733(pr_cdcooper => pr_cdcooper
                        , pr_nrdconta => rw_contaprej.nrdconta
                        , pr_dtmvtolt => rw_crapdat.dtmvtolt);
         FETCH cr_hist2733 INTO vr_vllan2733;
         CLOSE cr_hist2733;
         
         vr_vlsddisp:= vr_vlsddisp - vr_vllan2733;
         
         IF vr_vlsddisp <= 0 THEN
           CONTINUE;
         END IF;

         IF pr_cdcooper = 9 THEN -- Tratamento exclusivo para a cooperativa Transpocred do histórico 1017 (BNDES)            
           OPEN cr_hist1017(rw_contaprej.nrdconta, rw_crapdat.dtmvtolt);
           FETCH cr_hist1017 INTO vr_vldeb1017;
           CLOSE cr_hist1017;
           
           IF vr_vlsddisp = vr_vldeb1017 THEN
             -- Zera o valor do saldo liberado para operações na conta transitória
             PREJ0006.pc_zera_saldo_liberado_CT(pr_cdcooper => pr_cdcooper
                                              , pr_nrdconta => rw_contaprej.nrdconta);
				
		     CONTINUE; -- Avança para a próxima conta, pois não deve efetuar nenhum pagamento
           END IF;
         END IF;            
         
         -- Verificar se ainda possui saldo de prejuízo a pagar
         vr_vlsldprj := fn_obtem_saldo_prejuizo_cc(pr_cdcooper => pr_cdcooper, 
                                                   pr_nrdconta => rw_contaprej.nrdconta);
                                  
         IF nvl(vr_vlsldprj,0) > 0 THEN
           pc_pagar_prejuizo_cc(pr_cdcooper => pr_cdcooper
                           , pr_nrdconta => rw_contaprej.nrdconta
                           , pr_vlrpagto => least(vr_vlsddisp, vr_vlsldprj) -- Se o valor liberado é maior que o saldo a pagar, paga somente o saldo do prejuízo
                           , pr_cdcritic => vr_cdcritic
                           , pr_dscritic => vr_dscritic);

           -- Se não foi possível pagar o prejuízo
           IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             -- Bloqueia valor da CRAPLCM para a conta Transitória
             PREJ0006.pc_bloqueia_valor_para_CT(pr_cdcooper => pr_cdcooper
                                              , pr_nrdconta => rw_contaprej.nrdconta
                                              , pr_vllanmto => vr_vlsddisp
                                              , pr_cdcritic => vr_cdcritic
                                              , pr_dscritic => vr_dscritic);
                                              
             IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
               NULL; -- Incluir geração de LOG
             END IF;               
           END IF;
         END IF;
         
         -- Sera saldo liberado eventualmente da conta transitória ao longo do dia e não utilizado
         PREJ0006.pc_zera_saldo_liberado_CT(pr_cdcooper => pr_cdcooper
                                          , pr_nrdconta => rw_contaprej.nrdconta);
       END LOOP;

      COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic ||SQLERRM;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 1
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

END pc_pagar_prejuizo_cc_autom;

PROCEDURE pc_pagar_IOF_conta_prej(pr_cdcooper  IN craplcm.cdcooper%TYPE        -- Código da Cooperativa
                                 ,pr_nrdconta  IN craplcm.nrdconta%TYPE        -- Número da Conta
                                 ,pr_vllanmto  IN craplcm.vllanmto%TYPE        -- Valor do Lançamento
                                 ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE
                                 ,pr_vlbasiof  IN crapsld.vlbasiof%TYPE
                                 ,pr_idlautom  IN craplcm.idlautom%TYPE DEFAULT 0
                                 ,pr_cdcritic OUT NUMBER                       -- Código de críticia
                                 ,pr_dscritic OUT VARCHAR2) IS                -- Descrição da crítica

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_pagar_IOF_conta_prej
  --  Sigla    : RECP
  --  Autor    : Rangel Decker
  --  Data     : Junho/2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Realizar pagamento do IOF de conta em prejuizo
  --
  -- Alteração :
  --
  ---------------------------------------------------------------------------------------------------------------

    ---------------> CURSORES <-------------
    CURSOR cr_nrseqdig(pr_rowid ROWID) IS
    SELECT nrseqdig
      FROM craplcm
     WHERE ROWID = pr_rowid;

    -- VARIÁVEIS
    vr_vlioflan       NUMBER;
    vr_vliofpen       NUMBER := 0;
    vr_vlparcel       NUMBER := 0;
    vr_nrdocmto       NUMBER := 0;
    vr_nrseqdig       INTEGER;
    vr_des_reto       VARCHAR2(10);
    vr_tab_erro       GENE0001.typ_tab_erro;

    vr_des_erro  VARCHAR2(1000);

    vr_tab_retorno LANC0001.typ_reg_retorno; -- REcord com dados retornados pela "pc_gerar_lancamento_conta"
    vr_incrineg   PLS_INTEGER;

    TYPE typ_tab_rowid_iof IS TABLE OF ROWID
         INDEX BY PLS_INTEGER;
    vr_tab_rowid_iof typ_tab_rowid_iof;

    -- EXCEPTION
    vr_exc_erro     EXCEPTION;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);

    vr_cdhistor     NUMBER; -- Código do histórico para o lançamento
    vr_exc_saida exception;
  BEGIN
        BEGIN
           --Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
           LANC0001.pc_gerar_lancamento_conta(  pr_cdcooper => pr_cdcooper
                                              , pr_dtmvtolt => pr_dtmvtolt
                                              , pr_cdagenci  => 1
                                              , pr_cdbccxlt => 100
                                              , pr_nrdolote => 8450
                                              , pr_nrdconta => pr_nrdconta
                                              , pr_nrdctabb => pr_nrdconta
                                              , pr_nrdctitg => to_char(pr_nrdconta,'fm00000000')
                                              , pr_nrdocmto => fn_gera_nrdocmto_craplcm(pr_cdcooper => pr_cdcooper
                                                                                      , pr_nrdconta => pr_nrdconta
                                                                                      , pr_dtmvtolt => pr_dtmvtolt
                                                                                      , pr_cdhistor => 2323)
                                              , pr_cdhistor => 2323
                                              , pr_vllanmto => pr_vllanmto
                                              , pr_cdpesqbb => to_char(pr_vlbasiof,'fm000g000g000d00')
                                              , pr_inprolot => 1
                                              , pr_tplotmov => 1
                                              , pr_tab_retorno => vr_tab_retorno
                                              , pr_incrineg => vr_incrineg
                                              , pr_cdcritic => vr_cdcritic
                                              , pr_dscritic => vr_dscritic);

            IF vr_dscritic IS NOT NULL
                AND vr_incrineg = 0 THEN -- Erro de sistema/BD
                 RAISE vr_exc_saida;
            END IF;
        EXCEPTION
          WHEN vr_exc_saida THEN
            RAISE vr_exc_saida; -- RElança a exceção para ser tratada fora do bloco BEGIN...END
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tabela craplcm. '||SQLERRM;
            --Sair do programa
            RAISE vr_exc_saida;
        END;

         OPEN cr_nrseqdig(vr_tab_retorno.rowidlct);
         FETCH cr_nrseqdig INTO vr_nrseqdig;
         CLOSE cr_nrseqdig;

         --------------------------------------------------------------------------------------------------
         -- Atualizar os dados do IOF
         --------------------------------------------------------------------------------------------------
         TIOF0001.pc_altera_iof(pr_cdcooper     => pr_cdcooper
                               ,pr_nrdconta     => pr_nrdconta
                               ,pr_dtmvtolt     => pr_dtmvtolt
                               ,pr_tpproduto    => 5
                               ,pr_nrcontrato   => 0
                               ,pr_cdagenci_lcm => 1
                               ,pr_cdbccxlt_lcm => 100
                               ,pr_nrdolote_lcm => 8450
                               ,pr_nrseqdig_lcm => vr_nrseqdig
                               ,pr_cdcritic     => vr_cdcritic
                               ,pr_dscritic     => vr_dscritic);

         -- Condicao para verificar se houve critica
         IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;
  EXCEPTION
    WHEN  vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_IOF_CONTA_PREJUIZO: '||SQLERRM;
  END pc_pagar_IOF_conta_prej;

  PROCEDURE pc_resgata_cred_bloq_preju(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2) is
    /* .............................................................................

    Programa: pc_resgata_cred_bloq_preju
    Sistema : Ayllos Web
    Sigla   : PREJ
    Autor   : Reginaldo Rubens da Silva (AMcom)
    Data    : Junho/2018.                            Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua o resgate (desbloqueio) automático de créditos bloqueados por prejuízo (conta transitória).


    Alteracoes:
    ..............................................................................*/
    --

    -- Busca as contas em prejuízo para a cooperativa
    CURSOR cr_crapass IS
    SELECT ass.nrdconta
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.inprejuz = 1;
    rw_crapass cr_crapass%ROWTYPE;

    -- Busca créditos antigos (ocorridos antes de pr_dtrefere)
    CURSOR cr_crdant(pr_nrdconta tbcc_prejuizo_lancamento.nrdconta%TYPE
                   , pr_dtrefere tbcc_prejuizo_lancamento.dtmvtolt%TYPE) IS
    SELECT blq.dtmvtolt
         , blq.vllanmto
      FROM tbcc_prejuizo_lancamento blq
         , craphis his
     WHERE blq.cdcooper =  pr_cdcooper
       AND blq.nrdconta =  pr_nrdconta
       AND blq.dtmvtolt <= pr_dtrefere
       AND his.cdcooper = blq.cdcooper
             AND his.cdhistor = blq.cdhistor
       AND his.indebcre = 'C'
     ORDER BY blq.dtmvtolt;
    rw_crdant cr_crdant%ROWTYPE;

    -- Calcula soma dos lançamentos de crédito ocorridos após pr_dtrefere
    -- para descontar do saldo atual da conta transitória (bloqueios por prejuízo)
    CURSOR cr_somacred(pr_nrdconta tbcc_prejuizo_lancamento.nrdconta%TYPE
                     , pr_dtrefere tbcc_prejuizo_lancamento.dtmvtolt%TYPE) IS
    SELECT nvl(SUM(blq.vllanmto),0) vlsoma
      FROM tbcc_prejuizo_lancamento blq
         , craphis his
     WHERE blq.cdcooper = pr_cdcooper
       AND blq.nrdconta = pr_nrdconta
       AND blq.dtmvtolt > pr_dtrefere
       AND his.cdcooper = blq.cdcooper
             AND his.cdhistor = blq.cdhistor
       AND his.indebcre = 'C';

    -- Verifica se há acordo de cobrança ativo para a conta
    CURSOR cr_acordo(pr_nrdconta tbrecup_acordo.nrdconta%TYPE) IS
    SELECT a.nracordo
      FROM tbrecup_acordo a
         , tbrecup_acordo_contrato c
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND a.cdsituacao = 1
       AND c.nracordo = a.nracordo
       AND c.cdorigem = 1;

    -- Verifica se há marcações para a conta no CYBER
        CURSOR cr_cyber(pr_nrdconta crapcyc.nrdconta%TYPE) IS
        SELECT 1
          FROM  crapcyc cyc
         WHERE  cyc.cdcooper = pr_cdcooper
           AND  cyc.nrdconta = pr_nrdconta
             AND  cyc.cdorigem = 1
             AND  cyc.flgehvip = 1;

    -- Calendário de datas da cooperativa
    rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

    vr_vlsoma           NUMBER;   -- Soma dos créditos ocorridos após a data de referência
    vr_saldo_resgatar   NUMBER;   -- Valor do saldo disponível na conta transitória que pode ser resgatado
    vr_valor_transferir NUMBER;   -- Valor a transferir relativo a cada lançamento de crédito
    vr_dstextab craptab.dstextab%TYPE;
    vr_qtdictcc         NUMBER  :=0;
    vr_dtrefere         DATE;
    vr_nracordo         NUMBER;
    vr_total_resgatado  NUMBER := 0;
  BEGIN
      -- Buscar Parâmetros da TAB089
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPREST'
                                               ,pr_tpregist => 01);

      -- Parâmetro da quantidade de dias para resgate automático dos créditos
      vr_qtdictcc := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,128,3)),0);

      -- Recupera o calendário de datas da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Calcula a data de referência para os créditos a resgatar
      vr_dtrefere := rw_crapdat.dtmvtolt - vr_qtdictcc;

      -- Percorre as contas em prejuízo da cooperativa
      FOR rw_crapass IN cr_crapass LOOP
          -- Verifica se há acordo de cobrança ativo para a conta
          OPEN cr_acordo(rw_crapass.nrdconta);
          FETCH cr_acordo INTO vr_nracordo;

                    IF cr_acordo%FOUND THEN
                        CLOSE cr_acordo;

            continue; -- Não efetua os resgates de créditos para contas com acordo ativo
          END IF;

          CLOSE cr_acordo;

                    -- Verifica se a conta está marcada na CRAPCYC com as flags de cobrança extrajudicial ou judicial
                    OPEN cr_cyber(rw_crapass.nrdconta);
                    FETCH cr_cyber INTO vr_nracordo;

                    IF cr_cyber%FOUND THEN
                        CLOSE cr_cyber;

                        continue;
                    END IF;

                    CLOSE cr_cyber;

          -- Valor total dos créditos resgatados para a conta corrente
          vr_total_resgatado := 0;

          -- Obtém a soma dos créditos ocorridos após a data de referência
          OPEN cr_somacred(rw_crapass.nrdconta, vr_dtrefere);
          FETCH cr_somacred INTO vr_vlsoma;
          CLOSE cr_somacred;

          -- Calcula o saldo dos créditos a resgatar
          vr_saldo_resgatar := fn_sld_cta_prj(pr_cdcooper => pr_cdcooper
                                            , pr_nrdconta => rw_crapass.nrdconta
                                            , pr_exclbloq => 1);

          vr_saldo_resgatar := vr_saldo_resgatar - vr_vlsoma;

          -- Se não há créditos a resgatar, desconsidera a conta
          IF vr_saldo_resgatar <= 0 THEN
            continue;
          END IF;

          FOR rw_crdant IN cr_crdant(rw_crapass.nrdconta, vr_dtrefere) LOOP
            IF vr_saldo_resgatar > rw_crdant.vllanmto THEN
               vr_valor_transferir := rw_crdant.vllanmto; -- resgata o valor total do lancto de crédito
            ELSE
               vr_valor_transferir := vr_saldo_resgatar; -- resgata parte do valor do lancto de crédito
            END IF;

            -- Transfere lançamento da conta transitória para a conta corrente
            pc_gera_transf_cta_prj(pr_cdcooper => pr_cdcooper
                                 , pr_nrdconta => rw_crapass.nrdconta
                                 , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 , pr_vllanmto => vr_valor_transferir
                                 , pr_atsldlib => 0 --> Não alterar saldo liberado, pois será alterado nesta rotina
                                 , pr_cdcritic => vr_cdcritic
                                 , pr_dscritic => vr_dscritic);

            IF vr_dscritic IS NULL THEN
              vr_total_resgatado := vr_total_resgatado + nvl(vr_valor_transferir,0);
              COMMIT;
            ELSE
              ROLLBACK;
            END IF;

            -- Atualiza saldo disponível para resgate
            vr_saldo_resgatar := vr_saldo_resgatar - vr_valor_transferir;

            -- Se não há mais saldo disponível para resgate, ignora os lanctos de crédito restantes
            IF vr_saldo_resgatar = 0 THEN
               EXIT;
            END IF;
          END LOOP;

          -- Atualiza o saldo liberado para operações na conta corrente
          UPDATE tbcc_prejuizo
             SET vlsldlib = nvl(vlsldlib,0) + nvl(vr_total_resgatado,0)
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = rw_crapass.nrdconta
             AND dtliquidacao IS NULL;

          COMMIT;
      END LOOP;
 END pc_resgata_cred_bloq_preju;

  PROCEDURE pc_debita_juros60_prj(pr_cdcooper IN crapsld.cdcooper%TYPE   --> Coop conectada
                                 ,pr_nrdconta IN crapsld.nrdconta%TYPE   --> Número da conta
                                 ,pr_vlhist37 OUT NUMBER                 --> Valor debitador para o histórico 37
                                 ,pr_vlhist57 OUT NUMBER                 --> Valor debitador para o histórico 57
                                 ,pr_vlhist38 OUT NUMBER                 --> Valor debitador para o histórico 38
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2) IS
    /* .............................................................................

   Programa: pc_debita_juros60_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao: 18/12/2018

   Dados referentes ao programa:

   Frequencia: Srmpre que chamado

   Objetivo  : Debita juros +60 (Hist. 37, 38 e 57) provisionados para a conta corrente
                 que será transferida para prejuízo.

   Observacao:
   Alteracoes: 18/12/2018 - Correção para zerar os campos de juros+60 na CRAPSLD.
                            P450 - Reginaldo/AMcom
   ..............................................................................*/

     -- Busca valores para cálculo dos juros +60
     CURSOR cr_crapsld IS
        SELECT crapsld.vltsallq
              ,crapsld.vlsmnmes
              ,crapsld.vlsmnesp
              ,crapsld.vlsmnblq
              ,crapsld.vliofmes
              ,crapsld.vljuresp
              ,crapsld.vljurmes
        FROM crapsld crapsld
        WHERE crapsld.cdcooper = pr_cdcooper
        AND   crapsld.nrdconta = pr_nrdconta;
     rw_crapsld cr_crapsld%ROWTYPE;

     -- Busca dados do contrato de limite de crédito
     CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE
                        ,pr_nrdconta IN craplim.nrdconta%TYPE
                        ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                        ,pr_insitlim IN craplim.insitlim%TYPE) IS
      SELECT craplim.nrdconta
             ,craplim.cddlinha
             ,craplim.dtinivig
             ,craplim.vllimite
             ,rownum nrlinha
       FROM craplim craplim
       WHERE  craplim.cdcooper = pr_cdcooper
       AND    craplim.nrdconta = pr_nrdconta
       AND    craplim.tpctrlim = pr_tpctrlim
       AND    craplim.insitlim = pr_insitlim
       AND    rownum = 1
       ORDER BY craplim.cdcooper
              , craplim.nrdconta
              , craplim.dtinivig
              , craplim.tpctrlim
              , craplim.nrctrlim;
      rw_craplim cr_craplim%ROWTYPE;

    --Selecionar Cadastro de linhas de credito rotativos
    CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE
                      ,pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT craplrt.txmensal
      FROM craplrt craplrt
      WHERE  craplrt.cdcooper = pr_cdcooper
      AND    craplrt.cddlinha = pr_cddlinha;
    rw_craplrt cr_craplrt%ROWTYPE;

    -- Calendário de datas da cooperativa
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    vr_juros_negat craptab.dstextab%TYPE;
    vr_juros_saque craptab.dstextab%TYPE;
    vr_txjurneg NUMBER;
    vr_txjursaq NUMBER;

    vr_exc_erro EXCEPTION;

    vr_incrineg INTEGER;
    vr_tab_retorno LANC0001.typ_reg_retorno;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  BEGIN
    -- Define valor inicial dos parâmetros de retorno
    pr_vlhist37 := 0;
    pr_vlhist57 := 0;
    pr_vlhist38 := 0;

    -- Carrega calendário de datas da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    /*Carrega taxa de juros do cheque especial, da multa c/c, multa s/saque bloq. */
    vr_juros_negat:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'JUROSNEGAT'
                                               ,pr_tpregist => 1);

    IF vr_juros_negat IS NULL THEN
      vr_cdcritic:= 162;
      vr_dscritic:= NULL;

      RAISE vr_exc_erro;
    ELSE
      vr_txjurneg:= gene0002.fn_char_para_number(SUBSTR(vr_juros_negat,1,10)) / 100;
    END IF;

    /*Carrega taxa de juros de saque */
    vr_juros_saque:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'JUROSSAQUE'
                                               ,pr_tpregist => 1);

    IF vr_juros_saque IS NULL THEN
      vr_cdcritic:= 162;
      vr_dscritic:= NULL;

      RAISE vr_exc_erro;
    ELSE
      vr_txjursaq:= gene0002.fn_char_para_number(SUBSTR(vr_juros_saque,1,10)) / 100;
    END IF;

    -- Buscar dados do Saldo da Conta
    OPEN cr_crapsld ;
    FETCH cr_crapsld INTO rw_crapsld;

    IF cr_crapsld%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapsld;

      --Saldo Negativo mes
      IF nvl(rw_crapsld.vlsmnmes,0) <> 0 THEN
         pr_vlhist37 := (rw_crapsld.vlsmnmes * vr_txjurneg) * -1;

        -- Debita pr_vlhist37 na LCM
        LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdagenci => 1
                                          ,pr_cdbccxlt => 100
                                          ,pr_nrdolote => 8450
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrdctabb => pr_nrdconta
                                          ,pr_nrdctitg => to_char(pr_nrdconta, 'fm00000000')
                                          ,pr_nrdocmto => fn_gera_nrdocmto_craplcm(pr_cdcooper => pr_cdcooper
                                                                                                                           , pr_nrdconta => pr_nrdconta
                                                                                                                                                                 , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                                                                                                                                 , pr_cdhistor => 37)
                                          ,pr_cdhistor => 37
                                          ,pr_nrseqdig => 0
                                          ,pr_vllanmto => pr_vlhist37
                                          ,pr_inprolot => 1
                                          ,pr_tplotmov => 1
                                          ,pr_incrineg => vr_incrineg
                                          ,pr_tab_retorno => vr_tab_retorno
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
      END IF;

      -- Cheque especial
      IF rw_crapsld.vlsmnesp <> 0 OR
         (TO_CHAR(rw_crapdat.dtmvtolt,'mm') <> TO_CHAR(rw_crapdat.dtmvtoan,'mm') AND
         rw_crapsld.vljuresp <> 0) THEN
        --Selecionar informacoes dos limites de credito do associado
        OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_tpctrlim => 1
                        ,pr_insitlim => 2);
        FETCH cr_craplim INTO rw_craplim;

        IF cr_craplim%NOTFOUND THEN
          CLOSE cr_craplim;

          --Selecionar informacoes dos limites de credito do associado
          OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_tpctrlim => 1
                          ,pr_insitlim => 3);
          FETCH cr_craplim INTO rw_craplim;

          IF cr_craplim%NOTFOUND THEN
            CLOSE cr_craplim;

            --Selecionar informacoes dos limites de credito do associado
            OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_tpctrlim => 1
                          ,pr_insitlim => 1);
            FETCH cr_craplim INTO rw_craplim;

            IF cr_craplim%NOTFOUND THEN
              CLOSE cr_craplim;

              vr_cdcritic:= 105;

              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;

        IF cr_craplim%ISOPEN THEN
          CLOSE cr_craplim;
        END IF;

        --Selecionar informacoes das linhas de credito do associado
        OPEN cr_craplrt (pr_cdcooper => pr_cdcooper
                        ,pr_cddlinha => rw_craplim.cddlinha);
        FETCH cr_craplrt INTO rw_craplrt;

        IF cr_craplrt%NOTFOUND THEN
          CLOSE cr_craplrt;

          vr_cdcritic := 363;

          RAISE vr_exc_erro;
        END IF;

        CLOSE cr_craplrt;


        IF TO_CHAR(rw_crapdat.dtmvtolt,'mm') <> TO_CHAR(rw_crapdat.dtmvtoan,'mm') THEN -- Primeiro dia Útil
          pr_vlhist38 := rw_crapsld.vljuresp;
        ELSE
          pr_vlhist38:= (rw_crapsld.vlsmnesp * (rw_craplrt.txmensal / 100)) * -1;
        END IF;

        -- Debita pr_vlhist38 na LCM
        LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdagenci => 1
                                          ,pr_cdbccxlt => 100
                                          ,pr_nrdolote => 8450
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrdctabb => pr_nrdconta
                                          ,pr_nrdctitg => to_char(pr_nrdconta, 'fm00000000')
                                          ,pr_nrdocmto => fn_gera_nrdocmto_craplcm(pr_cdcooper => pr_cdcooper
                                                                                                                           , pr_nrdconta => pr_nrdconta
                                                                                                                                                                 , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                                                                                                                                 , pr_cdhistor => 38)
                                          ,pr_cdhistor => 38
                                          ,pr_nrseqdig => 0
                                          ,pr_vllanmto => pr_vlhist38
                                          ,pr_inprolot => 1
                                          ,pr_tplotmov => 1
                                          ,pr_incrineg => vr_incrineg
                                          ,pr_tab_retorno => vr_tab_retorno
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
      END IF;

      --Valor Bloqueado
      IF rw_crapsld.vlsmnblq <> 0 THEN
        pr_vlhist57 := (rw_crapsld.vlsmnblq * (vr_txjursaq)) * -1;

        -- Debita pr_vlhist57 na LCM
        LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdagenci => 1
                                          ,pr_cdbccxlt => 100
                                          ,pr_nrdolote => 8450
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrdctabb => pr_nrdconta
                                          ,pr_nrdctitg => to_char(pr_nrdconta, 'fm00000000')
                                          ,pr_nrdocmto => fn_gera_nrdocmto_craplcm(pr_cdcooper => pr_cdcooper
                                                                                                                           , pr_nrdconta => pr_nrdconta
                                                                                                                                                                 , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                                                                                                                                 , pr_cdhistor => 57)
                                          ,pr_cdhistor => 57
                                          ,pr_nrseqdig => 0
                                          ,pr_vllanmto => pr_vlhist57
                                          ,pr_inprolot => 1
                                          ,pr_tplotmov => 1
                                          ,pr_incrineg => vr_incrineg
                                          ,pr_tab_retorno => vr_tab_retorno
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
      END IF;

      -- Zera campos na CRAPSLD para evitar novo débito (indevido) dos valores
      UPDATE crapsld  sld
         SET vlsmnmes = 0
           , vlsmnesp = 0
           , vlsmnblq = 0
           , vljurmes = 0
           , vljuresp = 0
           , vljursaq = 0
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;

      IF vr_dscritic IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na PREJ0003.pc_debita_juros60_prj';
  END pc_debita_juros60_prj;

  -- Cria lançamentos no Extrato do Prejuízo referentes a transferência da conta
  PROCEDURE pc_lanca_transf_extrato_prj(pr_cdcooper          IN tbcc_prejuizo.cdcooper%TYPE
                                       , pr_nrdconta          IN tbcc_prejuizo.nrdconta%TYPE
                                      , pr_idprejuizo        IN tbcc_prejuizo.idprejuizo%TYPE
                                      , pr_vlsldprj          IN tbcc_prejuizo.vlsdprej%TYPE
                                      , pr_vljur60_ctneg     IN tbcc_prejuizo.vljur60_ctneg%TYPE
                                      , pr_vljur60_lcred     IN tbcc_prejuizo.vljur60_lcred%TYPE
                                      , pr_dtmvtolt          IN crapdat.dtmvtolt%TYPE
                                      , pr_tpope             IN VARCHAR
                                      , pr_cdcritic          OUT crapcri.cdcritic%TYPE
                                      , pr_dscritic          OUT crapcri.dscritic%TYPE) IS
    /* .............................................................................

   Programa: pc_lanca_transf_extrato_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado

   Objetivo  : Efetua lançamentos referentes a transferência para prejuízo de conta corrente
                 na tabela TBCC_PREJUIZO_DETALHE (extrato do prejuízo de conta corrente).

   Observacao:
   Alteracoes:
   ..............................................................................*/
  BEGIN
    -- Saldo devedor (hist. 2408/2412)
    pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                           , pr_nrdconta => pr_nrdconta
                           , pr_dtmvtolt => pr_dtmvtolt
                           , pr_cdhistor => CASE WHEN pr_tpope = 'N' THEN 2408 ELSE 2412 END
                           , pr_idprejuizo => pr_idprejuizo
                           , pr_vllanmto => pr_vlsldprj
                           , pr_cdcritic => vr_cdcritic
                          , pr_dscritic => vr_dscritic);

    IF pr_vljur60_ctneg > 0 THEN
      -- Juros +60 (Hist 37)
      pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                             , pr_nrdconta => pr_nrdconta
                             , pr_dtmvtolt => pr_dtmvtolt
                             , pr_cdhistor => 2716
                             , pr_idprejuizo => pr_idprejuizo
                             , pr_vllanmto => pr_vljur60_ctneg
                             , pr_cdcritic => vr_cdcritic
                            , pr_dscritic => vr_dscritic);
    END IF;

    IF pr_vljur60_lcred > 0 THEN
      -- Juros +60 (Hist 38)
      pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                             , pr_nrdconta => pr_nrdconta
                             , pr_dtmvtolt => pr_dtmvtolt
                             , pr_cdhistor => 2717
                             , pr_idprejuizo => pr_idprejuizo
                             , pr_vllanmto => pr_vljur60_lcred
                             , pr_cdcritic => vr_cdcritic
                            , pr_dscritic => vr_dscritic);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na pc_lanca_trans_extrato_prj: ' || SQLERRM;
  END pc_lanca_transf_extrato_prj;

 PROCEDURE pc_pagar_contrato_emprestimo(pr_cdcooper  IN crapepr.cdcooper%TYPE       -- Código da Cooperativa
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE       -- Número da Conta
                                        ,pr_cdagenci  IN NUMBER                      -- Código da agencia
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE       -- Número do contrato de empréstimo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- Número da parcela
                                        ,pr_cdoperad  IN VARCHAR2                    -- Código do operador
                                        ,pr_vlrpagto  IN NUMBER                      -- Valor pago
                                        ,pr_vlrabono  IN NUMBER DEFAULT 0            -- Valor do abono concedido (aplicado somente a contratos em prejuízo)
                                        ,pr_idorigem  IN NUMBER                      -- Indicador da origem
                                        ,pr_idvlrmin OUT NUMBER                      -- Indica que houve critica do valor minimo
                                        ,pr_vltotpag OUT NUMBER                      -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                      -- Código de críticia
                                        ,pr_dscritic OUT VARCHAR2) IS                -- Descrição da crítica
  /* .............................................................................

   Programa: pc_pagar_contrato_emprestimo
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado

   Objetivo  : Efetua o pagamento de um contrato de empréstimo a partir de uma conta corrente
                 transferida para prejuízo.

   Observacao:
   Alteracoes:
   ..............................................................................*/

    CURSOR cr_crapepr IS
      SELECT epr.inliquid
              ,epr.inprejuz
              ,epr.tpemprst
              ,epr.cdlcremp
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.vlsdeved
              ,epr.vlprejuz
              ,epr.vlsdprej
              ,epr.vlsprjat
              ,epr.vljuracu
              ,epr.vlttmupr
              ,epr.vlpgmupr
              ,epr.vlttjmpr
              ,epr.vlpgjmpr
              ,epr.vliofcpl
              ,epr.vlsdevat
              ,epr.dtultpag
              ,epr.qtprepag
              ,epr.flgpagto
              ,epr.txjuremp
              ,epr.cdcooper
              ,epr.cdagenci
              ,epr.dtmvtolt
              ,epr.vlpreemp
              ,epr.dtdpagto
              ,epr.qttolatr
              ,crawepr.txmensal
              ,crawepr.dtdpagto dtprivencto
              ,epr.vlsprojt
              ,epr.vlemprst
              ,epr.ROWID
              ,crawepr.idfiniof
           FROM crapepr epr
           JOIN crawepr
             ON crawepr.cdcooper = epr.cdcooper
            AND crawepr.nrdconta = epr.nrdconta
            AND crawepr.nrctremp = epr.nrctremp
          WHERE epr.cdcooper = pr_cdcooper
            AND epr.nrdconta = pr_nrdconta
            AND epr.nrctremp = pr_nrctremp;
    rw_crapepr   cr_crapepr%ROWTYPE;

    -- VARIÁVEIS
    vr_vlpagmto     NUMBER := pr_vlrpagto;
    vr_vltotpgt    NUMBER := 0; -- PJ637
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(1000);

     rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- EXCEPTIONS
    vr_exp_erro     EXCEPTION;

  BEGIN
    GENE0001.pc_set_modulo('BLQPREJU');

    -- 01 CARREGAR CRAPDAT
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haver¿ raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Buscar dados do contrato
    OPEN  cr_crapepr;
    FETCH cr_crapepr INTO rw_crapepr;

    -- Se o contrato não for encontrado
    IF cr_crapepr%NOTFOUND THEN
      -- Fecha o cursor
      CLOSE cr_crapepr;

      -- Deve retornar erro de execução
      vr_cdcritic := 0;
      vr_dscritic := 'Contrato '||TRIM(GENE0002.fn_mask_contrato(pr_nrctremp))||
                     ' do acordo não foi encontrado para a conta '||
                     TRIM(GENE0002.fn_mask_conta(pr_nrdconta))||'.';
      RAISE vr_exp_erro;
    END IF;

    -- Fecha o cursor
    CLOSE cr_crapepr;

    -- Verificar se o contrato já está LIQUIDADO   OU
    -- Se o contrato de PREJUIZO já foi TOTALMENTE PAGO
    IF (rw_crapepr.inliquid = 1 AND rw_crapepr.inprejuz = 0)  OR
       (rw_crapepr.inprejuz = 1 AND rw_crapepr.vlsdprej <= 0) THEN
      pr_vltotpag := 0; -- Indicar que nenhum valor foi pago para este contrato
      RETURN; -- Retornar da rotina
    END IF;

    -- Inicializa o indicador
    pr_idvlrmin := 0;

    -- Pagamento de Prejuizo
    IF rw_crapepr.inprejuz = 1 THEN
            pc_crps780_1(pr_cdcooper =>  pr_cdcooper,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_nrctremp => pr_nrctremp,
                                        pr_vlpagmto => vr_vlpagmto,
                                        pr_vldabono => pr_vlrabono,
                                        pr_cdagenci => 1,
                                        pr_cdoperad => pr_cdoperad,
                    pr_vltotpgt => vr_vltotpgt,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);

             IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
                 RAISE vr_exp_erro;
             ELSE
                 pr_vltotpag := vr_vlpagmto + pr_vlrabono;
             END IF;
    -- Folha de Pagamento
    ELSIF rw_crapepr.flgpagto = 1 THEN
      -- Realizar a chamada da rotina para pagamento de prejuizo
      EMPR9999.pc_pagar_emprestimo_folha(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_crapdat  => rw_crapdat
                               ,pr_nrctremp => pr_nrctremp
                               ,pr_nrparcel => pr_nrparcel
                               ,pr_cdlcremp => rw_crapepr.cdlcremp
                               ,pr_inliquid => rw_crapepr.inliquid
                               ,pr_qtprepag => rw_crapepr.qtprepag
                               ,pr_vlsdeved => rw_crapepr.vlsdeved
                               ,pr_vlsdevat => rw_crapepr.vlsdevat
                               ,pr_vljuracu => rw_crapepr.vljuracu
                               ,pr_txjuremp => rw_crapepr.txjuremp
                               ,pr_dtultpag => rw_crapepr.dtultpag
                               ,pr_vlparcel => vr_vlpagmto
                               ,pr_nmtelant => 'BLQPREJU'
                               ,pr_cdoperad => pr_cdcooper
                               ,pr_vltotpag => pr_vltotpag
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
      -- Se retornar erro da rotina
      IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        RAISE vr_exp_erro;
      END IF;

    -- Pagamento Normal
    ELSE

      -- Emprestimo TR
      IF rw_crapepr.tpemprst = 0 THEN
        -- Pagar empréstimo TR
            EMPR9999.pc_pagar_emprestimo_tr(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_crapdat  => rw_crapdat
                              ,pr_nrctremp => pr_nrctremp
                              ,pr_nrparcel => pr_nrparcel
                              ,pr_cdlcremp => rw_crapepr.cdlcremp
                              ,pr_inliquid => rw_crapepr.inliquid
                              ,pr_qtprepag => rw_crapepr.qtprepag
                              ,pr_vlsdeved => rw_crapepr.vlsdeved
                              ,pr_vlsdevat => rw_crapepr.vlsdevat
                              ,pr_vljuracu => rw_crapepr.vljuracu
                              ,pr_txjuremp => rw_crapepr.txjuremp
                              ,pr_dtultpag => rw_crapepr.dtultpag
                              ,pr_vlparcel => vr_vlpagmto
                              ,pr_idorigem => 1
                              ,pr_nmtelant => 'BLQPREJU'
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_vltotpag => pr_vltotpag
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
        -- Se retornar erro da rotina
        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
          RAISE vr_exp_erro;
        END IF;

      -- Emprestimo PP
      ELSIF rw_crapepr.tpemprst = 1 THEN
        -- Pagar empréstimo PP
         EMPR9999.pc_pagar_emprestimo_pp(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_crapdat  => rw_crapdat
                               ,pr_nrctremp => pr_nrctremp
                               ,pr_nrparcel => pr_nrparcel
                               ,pr_vlsdeved => rw_crapepr.vlsdeved
                               ,pr_vlsdevat => rw_crapepr.vlsdevat
                               ,pr_vlparcel => vr_vlpagmto
                               ,pr_idorigem => 1
                               ,pr_nmtelant => 'BLQPREJU'
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_idvlrmin => pr_idvlrmin
                               ,pr_vltotpag => pr_vltotpag
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
       -- Se retornar erro da rotina
        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
          RAISE vr_exp_erro;
        END IF;
      ELSIF  rw_crapepr.tpemprst = 2 THEN
          EMPR9999.pc_pagar_emprestimo_pos(pr_cdcooper => pr_cdcooper         -- Código da Cooperativa
                                           ,pr_nrdconta       => pr_nrdconta         -- Número da Conta
                                           ,pr_cdagenci       => pr_cdagenci         -- Código da agencia
                                           ,pr_crapdat        => rw_crapdat          -- Datas da cooperativa
                                           ,pr_nrctremp       => pr_nrctremp         -- Número do contrato de empréstimo
                                           ,pr_cdlcremp       => rw_crapepr.cdlcremp
                                           ,pr_vlemprst       => rw_crapepr.vlemprst
                                           ,pr_txmensal       => rw_crapepr.txmensal
                                           ,pr_dtprivencto    => rw_crapepr.dtprivencto
                                                                                     ,pr_dtmvtolt       => rw_crapepr.dtmvtolt
                                           ,pr_vlsprojt       => rw_crapepr.vlsprojt
                                           ,pr_qttolar        => rw_crapepr.qttolatr
                                           ,pr_nrparcel       => pr_nrparcel               -- Número da parcela
                                           ,pr_vlsdeved       => rw_crapepr.vlsdeved       -- Valor do saldo devedor
                                           ,pr_vlsdevat       => rw_crapepr.vlsdevat       -- Valor anterior do saldo devedor
                                                                                     ,pr_vlrpagar       => vr_vlpagmto
                                           ,pr_idorigem       => pr_idorigem               -- Indicador da origem
                                           ,pr_nmtelant       => 'BLQPREJU'                -- Nome da tela
                                           ,pr_cdoperad       => pr_cdoperad               -- Código do operador
                                           ,pr_idvlrmin       => pr_idvlrmin               -- Indica que houve critica do valor minimo
                                           ,pr_vltotpag       => pr_vltotpag               -- Retorno do valor pago
                                           ,pr_cdcritic       => vr_cdcritic                -- Código de críticia                     -- Código de críticia
                                           ,pr_dscritic       => vr_dscritic);                     -- Descrição da crítica
           -- Se retornar erro da rotina
            IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
              RAISE vr_exp_erro;
            END IF;

      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exp_erro THEN
      -- Retornar total pago como zero
      pr_vltotpag := 0;
      -- Deve retornar erro de execução
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Retornar total pago como zero
      pr_vltotpag := 0;
      -- Deve retornar erro de execução
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_CONTRATO_EMPRESTIMO: '||SQLERRM;
  END pc_pagar_contrato_emprestimo;

  PROCEDURE pc_atualiza_sld_lib_prj(pr_cdcooper IN tbcc_prejuizo.cdcooper%TYPE
                                  , pr_nrdconta IN tbcc_prejuizo.nrdconta%TYPE
                                  , pr_vlrdebto IN tbcc_prejuizo.vlsldlib%TYPE
                                  , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  , pr_dscritic OUT crapcri.dscritic%TYPE
                                  , pr_des_erro OUT VARCHAR) IS
    /* .............................................................................

   Programa: pc_atualiza_sld_lib_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado

   Objetivo  : Atualiza o valor do saldo dos créditos liberados para operações na conta transitória.

   Observacao:
   Alteracoes:
   ..............................................................................*/

    -- Busca o saldo liberado para operações na C/C
    CURSOR cr_sldlib IS
    SELECT vlsldlib
         , ROWID
      FROM tbcc_prejuizo
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND dtliquidacao IS NULL;
    rw_sldlib cr_sldlib%ROWTYPE;

    vr_exc_erro EXCEPTION;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  BEGIN
    pr_des_erro := 'OK';
    pr_cdcritic := 0;
    pr_dscritic := NULL;

    OPEN cr_sldlib;
    FETCH cr_sldlib INTO rw_sldlib;
    CLOSE cr_sldlib;

    -- Se o valor do débito é maior que o saldo liberado para operações na C/C
    IF rw_sldlib.vlsldlib < pr_vlrdebto THEN
      vr_dscritic := 'Saldo liberado para operações menor que o valor do débito informado.';

      RAISE vr_exc_erro;
    END IF;

    BEGIN
      -- Atualiza o saldo liberado, debitando o valor informado
      UPDATE tbcc_prejuizo prj
         SET prj.vlsldlib = prj.vlsldlib - pr_vlrdebto
       WHERE ROWID = rw_sldlib.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar o saldo liberado para operações na C/C.';

        RAISE vr_exc_erro;
    END;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro não tratado na PREJ0003.pc_atualiza_sld_lib_prj: ' || SQLERRM;
       pr_des_erro := 'NOK';
  END pc_atualiza_sld_lib_prj;

  PROCEDURE pc_gera_lcto_extrato_prj(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE
                                   , pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE
                                   , pr_dtmvtolt IN tbcc_prejuizo_detalhe.dtmvtolt%TYPE
                                   , pr_cdhistor IN tbcc_prejuizo_detalhe.cdhistor%TYPE
                                   , pr_idprejuizo IN tbcc_prejuizo_detalhe.idprejuizo%TYPE DEFAULT NULL
                                   , pr_vllanmto IN tbcc_prejuizo_detalhe.vllanmto%TYPE
                                   , pr_nrctremp IN tbcc_prejuizo_detalhe.nrctremp%TYPE DEFAULT 0
                                   , pr_cdoperad IN tbcc_prejuizo_detalhe.cdoperad%TYPE DEFAULT '1'
                                   , pr_dthrtran IN tbcc_prejuizo_detalhe.dthrtran%TYPE DEFAULT NULL
                                   , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   , pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* .............................................................................

   Programa: pc_atualiza_sld_lib_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado

   Objetivo  : Gera um lançamento na TBCC_PREJUIZO_DETALHE (extrato do prejuízo de conta corrente).

   Observacao:
   Alteracoes:
   ..............................................................................*/

    CURSOR cr_prejuizo IS
    SELECT idprejuizo
      FROM tbcc_prejuizo
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
         AND dtliquidacao IS NULL;

    vr_idprejuizo tbcc_prejuizo_detalhe.idprejuizo%TYPE := pr_idprejuizo;

  BEGIN
    pr_cdcritic := 0;
    pr_dscritic := NULL;

        IF vr_idprejuizo IS NULL THEN
            OPEN cr_prejuizo;
            FETCH cr_prejuizo INTO vr_idprejuizo;
            CLOSE cr_prejuizo;
        END IF;

    BEGIN
      INSERT INTO tbcc_prejuizo_detalhe (
        dtmvtolt
       ,nrdconta
       ,cdhistor
       ,vllanmto
       ,dthrtran
       ,cdoperad
       ,cdcooper
       ,idprejuizo
       ,nrctremp
      )
      VALUES (
        pr_dtmvtolt
       ,pr_nrdconta
       ,pr_cdhistor
       ,pr_vllanmto
       ,nvl(pr_dthrtran, SYSDATE)
       ,pr_cdoperad
       ,pr_cdcooper
       ,vr_idprejuizo
       ,pr_nrctremp
      );
    EXCEPTION
         WHEN OTHERS THEN
           pr_dscritic := 'Erro não tratado na PREJ0003.pc_gera_lcto_extrato_prj: ' || SQLERRM;
    END;
  END pc_gera_lcto_extrato_prj;

  PROCEDURE pc_sld_cta_prj(pr_cdcooper IN NUMBER
                         , pr_nrdconta IN NUMBER
                         , pr_vlrsaldo OUT NUMBER
                         , pr_cdcritic OUT crapcri.cdcritic%TYPE
                         , pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* .............................................................................

   Programa: pc_sld_cta_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado

   Objetivo  : Retorna o saldo da conta transitória (créditos bloqueados por prejuízo).

   Observacao:
   Alteracoes:
   ..............................................................................*/
  BEGIN
    pr_cdcritic := 0;
    pr_dscritic := NULL;

    pr_vlrsaldo := fn_sld_cta_prj(pr_cdcooper => pr_cdcooper
                                , pr_nrdconta => pr_nrdconta);
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro não tratado na pc_sld_conta_prj: ' || SQLERRM;
  END;

  PROCEDURE pc_busca_sit_bloq_preju(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------

  Programa : pc_busca_sit_bloq_preju
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Sigla    : CRED
  Autor    : Diego Simas
  Data     : Agosto/2018                          Ultima atualizacao:

  Dados referentes ao programa:

  Frequencia: -----
  Objetivo  : Consulta situação da conta e se já ouve alguma vez que a
              conta foi transferida para prejuízo.

  Alterações:

  -------------------------------------------------------------------------------------------------------------*/

    -- CURSORES --

    --> Consultar se já houve prejuizo nessa conta
    CURSOR cr_prejuizo(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                       pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
      SELECT t.nrdconta
        FROM tbcc_prejuizo t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    rw_prejuizo cr_prejuizo%ROWTYPE;

    --> Consultar crapass
    CURSOR cr_crapass(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                      pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
      SELECT c.inprejuz
        FROM crapass c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);

    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_inprejuz INTEGER := 0;
    vr_ocopreju VARCHAR2(1) := 'N';

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;
  BEGIN
    pr_des_erro := 'OK';
    pr_cdcritic := NULL;
    pr_dscritic := NULL;

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -----> PROCESSAMENTO PRINCIPAL <-----
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%FOUND THEN
      vr_inprejuz := rw_crapass.inprejuz;
    END IF;
        
        CLOSE cr_crapass;

    OPEN cr_prejuizo(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_prejuizo INTO rw_prejuizo;

    IF cr_prejuizo%FOUND THEN
      vr_ocopreju := 'S';
    ELSE
      vr_ocopreju := 'N';
    END IF;

        CLOSE cr_prejuizo;

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_qtregist,
                           pr_tag_nova => 'inprejuz',
                           pr_tag_cont => vr_inprejuz,
                           pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_qtregist,
                           pr_tag_nova => 'ocopreju',
                           pr_tag_cont => vr_ocopreju,
                           pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_sit_bloq_preju --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_busca_sit_bloq_preju;

  PROCEDURE pc_cred_disp_prj(pr_cdcooper IN NUMBER
                           , pr_nrdconta IN NUMBER
                           , pr_vlrsaldo OUT NUMBER
                           , pr_cdcritic OUT crapcri.cdcritic%TYPE
                           , pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* .............................................................................

   Programa: pc_cred_disp_prj
   Sistema : Aimaro
   Sigla   : PREJ
   Autor   : Reginaldo (AMcom)
   Data    : Setembro/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamado

   Objetivo  : Retorna o saldo dos créditos liberados para oprerações na conta transitória.

   Observacao:
   Alteracoes:
   ..............................................................................*/
    BEGIN
      pr_cdcritic := 0;
      pr_dscritic := NULL;

      pr_vlrsaldo := fn_cred_disp_prj(pr_cdcooper => pr_cdcooper
                                    , pr_nrdconta => pr_nrdconta);
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na pc_cred_disp_prj: ' || SQLERRM;
  END;

  PROCEDURE pc_busca_pagto_estorno_prj(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                      ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                      ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2)IS            --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_busca_pagto_estorno_prj
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Diego Simas
    Data     : Agosto/2018                          Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Rotina para consultar o último pagamento via conta transitória (Bloqueado Prejuízo).
    Alterações :

    -------------------------------------------------------------------------------------------------------------*/

    -- CURSORES --

    --> Consultar ultimo lancamento de prejuizo
    CURSOR cr_detalhe_ult_lanc(pr_cdcooper tbcc_prejuizo_detalhe.cdcooper%TYPE,
                               pr_nrdconta tbcc_prejuizo_detalhe.nrdconta%TYPE,
                               pr_dtmvtolt tbcc_prejuizo_detalhe.dtmvtolt%TYPE)IS
    SELECT d.dthrtran,d.idprejuizo
      FROM tbcc_prejuizo_detalhe d
     WHERE d.cdcooper = pr_cdcooper
       AND d.nrdconta = pr_nrdconta
       AND d.cdhistor IN (2733, --> REC. PREJUIZO
                          2723, --> ABONO PREJUIZO
                          2725, --> BX.PREJ.PRIN
                          2727, --> BX.PREJ.JUROS
                          2729) --> BX.PREJ.JUROS                          
       AND to_char(d.dtmvtolt, 'MM/YYYY') = to_char(pr_dtmvtolt, 'MM/YYYY') 
  ORDER BY d.dtmvtolt DESC, d.dthrtran DESC, d.cdhistor DESC;
    rw_detalhe_ult_lanc cr_detalhe_ult_lanc%ROWTYPE;

    --> Consultar todos os historicos para soma à estornar
    --> 2723 – Abono de prejuízo
    -->  2725 – Pagamento do valor principal do prejuízo
    -->  2727 – Pagamento dos juros +60 da transferência para prejuízo
    -->  2729 – Pagamento dos juros remuneratórios do prejuízo
    -->  2721 – Débito para pagamento do prejuízo (para fins contábeis)
    CURSOR cr_detalhe_tot_est(pr_cdcooper tbcc_prejuizo_detalhe.cdcooper%TYPE,
                              pr_nrdconta tbcc_prejuizo_detalhe.nrdconta%TYPE,
                              pr_dthrtran tbcc_prejuizo_detalhe.dthrtran%TYPE)IS
    SELECT SUM(d.vllanmto) total_estorno
      FROM tbcc_prejuizo_detalhe d
          ,tbcc_prejuizo c
     WHERE d.cdcooper = pr_cdcooper
       AND d.nrdconta = pr_nrdconta
       AND trunc(d.dthrtran) = trunc(pr_dthrtran)
       AND(d.cdhistor = 2725  --> 2725 – Pagamento do valor principal do prejuízo
        OR d.cdhistor = 2727  --> 2727 – Pagamento dos juros +60 da transferência para prejuízo
        OR d.cdhistor = 2729)  --> 2729 – Pagamento dos juros remuneratórios do prejuízo
       AND c.cdcooper = d.cdcooper
       AND c.nrdconta = d.nrdconta
       AND c.dtliquidacao IS NULL
  ORDER BY d.dtmvtolt, d.dthrtran DESC;
    rw_detalhe_tot_est cr_detalhe_tot_est%ROWTYPE;

    -- Consultar se já houve estorno
    CURSOR cr_ja_estornou(pr_idprejuizo tbcc_prejuizo_detalhe.idprejuizo%TYPE)IS
    SELECT 1
          FROM dual 
         WHERE (SELECT NVL(MAX(prj.idlancto), 0) FROM tbcc_prejuizo_detalhe prj WHERE prj.idprejuizo = pr_idprejuizo AND cdhistor IN (2722,2724)) >
           (SELECT NVL(MAX(prj.idlancto), 0) FROM tbcc_prejuizo_detalhe prj WHERE prj.idprejuizo = pr_idprejuizo AND cdhistor IN (2721,2723));
    rw_ja_estornou cr_ja_estornou%ROWTYPE;


    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);
    vr_exc_saida EXCEPTION;

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis Locais
    vr_qtregist   INTEGER := 0;
    vr_clob       CLOB;
    vr_xml_temp   VARCHAR2(32726) := '';
    tot_estorno   crapepr.vljurmes%TYPE;
    vr_inprejuz   BOOLEAN;
    rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;

  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
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

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;

      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -----> PROCESSAMENTO PRINCIPAL <-----

    vr_inprejuz := fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta);

    IF vr_inprejuz = TRUE THEN

       OPEN cr_detalhe_ult_lanc(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt);

       FETCH cr_detalhe_ult_lanc INTO rw_detalhe_ult_lanc;

       IF cr_detalhe_ult_lanc%FOUND THEN
          CLOSE cr_detalhe_ult_lanc;

          OPEN cr_ja_estornou(pr_idprejuizo => rw_detalhe_ult_lanc.idprejuizo);
          FETCH cr_ja_estornou INTO rw_ja_estornou;

          IF cr_ja_estornou%NOTFOUND THEN

             CLOSE cr_ja_estornou;

             OPEN cr_detalhe_tot_est(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dthrtran => rw_detalhe_ult_lanc.dthrtran);

             FETCH cr_detalhe_tot_est INTO rw_detalhe_tot_est;

             tot_estorno := 0;

             IF cr_detalhe_tot_est%FOUND THEN
                tot_estorno := rw_detalhe_tot_est.total_estorno;
                IF nvl(tot_estorno,0) = 0 THEN
                   vr_cdcritic := 0;
                   vr_dscritic := 'Não existem valores lançados para efetuar o estorno!';
                   RAISE vr_exc_erro;
                END IF;
             END IF;

            CLOSE cr_detalhe_tot_est;

            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_qtregist,
                                   pr_tag_nova => 'totestor',
                                   pr_tag_cont => tot_estorno,
                                   pr_des_erro => vr_dscritic);

            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_qtregist,
                                   pr_tag_nova => 'datalanc',
                                   pr_tag_cont => to_char(TRUNC(rw_detalhe_ult_lanc.dthrtran), 'DD/MM/YYYY'),
                                   pr_des_erro => vr_dscritic);
          ELSE
            CLOSE cr_ja_estornou;
            vr_cdcritic := 0;
            vr_dscritic := 'Não existem valores lançados para efetuar o estorno!';
            RAISE vr_exc_erro;
          END IF;
       ELSE
          CLOSE cr_detalhe_ult_lanc;
          vr_cdcritic := 0;
          vr_dscritic := 'Não existem pagamentos de prejuízo de C/C para estorno!';
          RAISE vr_exc_erro;
       END IF;
    ELSE
      vr_cdcritic := 0;
      vr_dscritic := 'Esta conta não está em prejuízo!';
      RAISE vr_exc_erro;
    END IF;

    pr_cdcritic := NULL;
    pr_dscritic := NULL;


  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_pagto_estorno_prj --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_busca_pagto_estorno_prj;

  PROCEDURE pc_grava_estorno_preju(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE --> Conta do cooperado
                                  ,pr_totalest IN tbcc_prejuizo_detalhe.vllanmto%TYPE --> Total a estornar
                                  ,pr_justific IN VARCHAR2                            --> Descrição da justificativa
                                  --> CAMPOS IN/OUT PADRÃO DA MENSAGERIA
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2)IS            --Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_grava_estorno_preju
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Diego Simas
    Data     : Agosto/2018                          Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia :
    Objetivo   : Rotina responsável por gerar os históricos específicos para o estorno da CC em prejuízo.
    Alterações :

                 25/09/2018 - Validar campo justificativa do estorno da Conta Transitória
                              PJ 450 - Diego Simas (AMcom)

                 16/10/2018 - Ajuste na rotina para realizar o estorno do abono na conta corrente do cooperado.
                              PRJ450-Regulatorio(Odirlei-AMcom)


    -------------------------------------------------------------------------------------------------------------*/

    -- CURSORES --

    --> Consultar ultimo lancamento de prejuizo
    CURSOR cr_detalhe_ult_lanc(pr_cdcooper tbcc_prejuizo_detalhe.cdcooper%TYPE,
                               pr_nrdconta tbcc_prejuizo_detalhe.nrdconta%TYPE)IS
    SELECT d.dthrtran,
           d.idprejuizo
      FROM tbcc_prejuizo_detalhe d
     WHERE d.cdcooper = pr_cdcooper
       AND d.nrdconta = pr_nrdconta
       AND d.cdhistor IN (2733, --> REC. PREJUIZO
                          2723, --> ABONO PREJUIZO
                          2725, --> BX.PREJ.PRIN
                          2727, --> BX.PREJ.JUROS
                          2729) --> BX.PREJ.JUROS        
  ORDER BY d.dtmvtolt DESC, d.dthrtran DESC;
    rw_detalhe_ult_lanc cr_detalhe_ult_lanc%ROWTYPE;

    --> Consultar todos os historicos para soma à estornar
    --> 2723 – Abono de prejuízo
    --> 2725 – Pagamento do valor principal do prejuízo
    --> 2727 – Pagamento dos juros +60 da transferência para prejuízo
    --> 2729 – Pagamento dos juros remuneratórios do prejuízo
    --> 2323 – Pagamento de IOF provisionado
    --> 2721 – Débito para pagamento do prejuízo (para fins contábeis)
    CURSOR cr_detalhe_tot_est(pr_cdcooper tbcc_prejuizo_detalhe.cdcooper%TYPE,
                              pr_nrdconta tbcc_prejuizo_detalhe.nrdconta%TYPE,
                              pr_dthrtran tbcc_prejuizo_detalhe.dthrtran%TYPE)IS
    SELECT d.cdhistor
          ,d.vllanmto
          ,d.idprejuizo
      FROM tbcc_prejuizo_detalhe d
     WHERE d.cdcooper = pr_cdcooper
       AND d.nrdconta = pr_nrdconta
       AND d.dthrtran = pr_dthrtran
       AND(d.cdhistor = 2723  --> 2723 – Abono de prejuízo
        OR d.cdhistor = 2725  --> 2725 – Pagamento do valor principal do prejuízo
        OR d.cdhistor = 2727  --> 2727 – Pagamento dos juros +60 da transferência para prejuízo
        OR d.cdhistor = 2729  --> 2729 – Pagamento dos juros remuneratórios do prejuízo
                OR d.cdhistor = 2323  --> 2323 – Pagamento do IOF
        OR d.cdhistor = 2721  --> 2721 – Débito para pagamento do prejuízo (para fins contábeis)
        OR d.cdhistor = 2733) --> 2733 - Débito para pagamento do prejuízo (para fins contábeis)
  ORDER BY d.dtmvtolt, d.dthrtran DESC, d.cdhistor ASC;
    rw_detalhe_tot_est cr_detalhe_tot_est%ROWTYPE;
        
     -- Carrega o calendário de datas da cooperativa
     rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);
    vr_exc_saida EXCEPTION;

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_cdhistor tbcc_prejuizo_detalhe.cdhistor%TYPE;
    vr_valoriof tbcc_prejuizo_detalhe.vllanmto%TYPE;
    vr_valordeb tbcc_prejuizo_detalhe.vllanmto%TYPE;
    vr_nrdocmto NUMBER;

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;
        
        vr_incrineg INTEGER;
        vr_tab_retorno LANC0001.typ_reg_retorno;
        vr_nrseqdig craplcm.nrseqdig%TYPE;
        
        vr_vlest_princ NUMBER;
        vr_vlest_jur60 NUMBER;
        vr_vlest_jupre NUMBER;
        vr_vlest_abono NUMBER;
        vr_vlest_IOF   NUMBER := 0;
    vr_vldpagto    NUMBER := 0;
    vr_vlest_saldo NUMBER := 0;
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
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
        
        OPEN BTCH0001.cr_crapdat(pr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        CLOSE BTCH0001.cr_crapdat;

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -----> PROCESSAMENTO PRINCIPAL <-----
    
    IF nvl(ltrim(pr_justific), 'VAZIO') = 'VAZIO'  THEN
       vr_cdcritic := 0;
       vr_dscritic := 'Obrigatório o preenchimento do campo justificativa';
       RAISE vr_exc_erro;
    END IF;
    
    OPEN cr_detalhe_ult_lanc(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta);

    FETCH cr_detalhe_ult_lanc INTO rw_detalhe_ult_lanc;

    IF cr_detalhe_ult_lanc%FOUND THEN
       CLOSE cr_detalhe_ult_lanc;
       FOR rw_detalhe_tot_est IN cr_detalhe_tot_est(pr_cdcooper => pr_cdcooper
                                                   ,pr_nrdconta => pr_nrdconta
                                                   ,pr_dthrtran => rw_detalhe_ult_lanc.dthrtran) LOOP

           IF rw_detalhe_tot_est.cdhistor = 2723 THEN
              -- 2724 <- ESTORNO - > Abono de prejuízo
                            vr_vlest_abono := rw_detalhe_tot_est.vllanmto;
              vr_cdhistor := 2724;
           ELSIF rw_detalhe_tot_est.cdhistor = 2725 THEN
              -- 2726 <- ESTORNO - > Pagamento do valor principal do prejuízo
              vr_cdhistor := 2726;
              vr_vldpagto := nvl(vr_vldpagto,0) + nvl(rw_detalhe_tot_est.vllanmto,0);
              vr_vlest_saldo := nvl(rw_detalhe_tot_est.vllanmto,0);
           ELSIF rw_detalhe_tot_est.cdhistor = 2727 THEN
              -- 2728 <- ESTORNO - > Pagamento dos juros +60 da transferência para prejuízo
                            vr_vlest_jur60 := rw_detalhe_tot_est.vllanmto;
              vr_cdhistor := 2728;
              vr_vldpagto := nvl(vr_vldpagto,0) + nvl(rw_detalhe_tot_est.vllanmto,0);
           ELSIF rw_detalhe_tot_est.cdhistor = 2729 THEN
              -- 2730 <- ESTORNO - > Pagamento dos juros remuneratórios do prejuízo
                            vr_vlest_jupre := rw_detalhe_tot_est.vllanmto;
              vr_cdhistor := 2730;
              vr_vldpagto := nvl(vr_vldpagto,0) + nvl(rw_detalhe_tot_est.vllanmto,0);
                     ELSIF rw_detalhe_tot_est.cdhistor = 2323 THEN
              -- 2323 <- ESTORNO - > Pagamento do IOF
                            vr_vlest_IOF := rw_detalhe_tot_est.vllanmto;
           ELSIF rw_detalhe_tot_est.cdhistor = 2721 THEN
              -- 2722 <- ESTORNO - > Débito para pagamento do prejuízo (para fins contábeis)
              vr_cdhistor := 2722;
           ELSIF rw_detalhe_tot_est.cdhistor = 2733 THEN
              -- 2732 <- ESTORNO - > Débito para pagamento do prejuízo
              vr_cdhistor := 2732;
                            vr_vlest_princ := rw_detalhe_tot_est.vllanmto;
              vr_valordeb := rw_detalhe_tot_est.vllanmto;
           END IF;

           IF rw_detalhe_tot_est.cdhistor NOT IN (2323,2723) THEN
                            -- insere o estorno com novo histórico
                            BEGIN
                                INSERT INTO tbcc_prejuizo_detalhe (
                                     dtmvtolt
                                    ,nrdconta
                                    ,cdhistor
                                    ,vllanmto
                                    ,dthrtran
                                    ,cdoperad
                                    ,cdcooper
                                    ,idprejuizo
                                    ,dsjustificativa
                                 )
                                 VALUES (
                                     rw_crapdat.dtmvtolt
                                    ,pr_nrdconta
                                    ,vr_cdhistor
                                    ,rw_detalhe_tot_est.vllanmto
                                    ,SYSDATE
                                    ,vr_cdoperad
                                    ,pr_cdcooper
                                    ,rw_detalhe_tot_est.idprejuizo
                                    ,pr_justific
                                 );
                            EXCEPTION
                                WHEN OTHERS THEN
                                    vr_cdcritic := 0;
                                    vr_dscritic := 'Erro de insert na tbcc_prejuizo_detalhe: '||SQLERRM;
                                    RAISE vr_exc_erro;
                            END;
                        END IF;
       END LOOP;

       
       
      IF vr_valordeb > 0 THEN
       -- Insere lançamento com histórico 2738
       BEGIN
         INSERT INTO TBCC_PREJUIZO_LANCAMENTO (
                 dtmvtolt
               , cdagenci
               , nrdconta
               , nrdocmto
               , cdhistor
               , vllanmto
               , dthrtran
               , cdoperad
               , cdcooper
               , cdorigem
          )
          VALUES (
                 rw_crapdat.dtmvtolt
               , vr_cdagenci
               , pr_nrdconta
               , 999992722
               , 2738 
               , vr_valordeb
               , SYSDATE
               , vr_cdoperad
               , pr_cdcooper
               , 5
          );
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro de insert na TBCC_PREJUIZO_LANCAMENTO: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
            
            vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                    ,pr_nmdcampo => 'NRSEQDIG'
                                    ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                    to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
                                    '1;100;650009');

        vr_nrdocmto := 999992722; 
        LOOP
          
            LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       , pr_cdagenci => vr_cdagenci
                                       , pr_cdbccxlt => vr_nrdcaixa
                                       , pr_nrdolote => 650009
                                       , pr_nrdconta => pr_nrdconta
                                         , pr_nrdocmto => vr_nrdocmto
                                       , pr_cdhistor => 2719
                                       , pr_nrseqdig => vr_nrseqdig
                                       , pr_vllanmto => vr_valordeb
                                       , pr_nrdctabb => pr_nrdconta
                                       , pr_cdpesqbb => 'ESTORNO DE PAGAMENTO DE PREJUÍZO DE C/C'
                                       , pr_dtrefere => rw_crapdat.dtmvtolt
                                       , pr_hrtransa => gene0002.fn_busca_time
                                         , pr_cdoperad => vr_cdoperad
                                       , pr_cdcooper => pr_cdcooper
                                       , pr_cdorigem => 5
                                                                             , pr_incrineg => vr_incrineg
                                                                             , pr_tab_retorno => vr_tab_retorno
                                                                             , pr_cdcritic => vr_cdcritic
                                                                             , pr_dscritic => vr_dscritic);
                                                                             
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            IF vr_incrineg = 0 THEN
              IF vr_cdcritic = 92 THEN
                vr_nrdocmto := vr_nrdocmto + 10000;
                continue;
            END IF;
              RAISE vr_exc_erro;
            ELSE
                RAISE vr_exc_erro;
            END IF;
          END IF;
          
          EXIT;
        
        END LOOP;
        
        
      END IF;
      
      vr_vldpagto := nvl(vr_vldpagto,0) - nvl(vr_valordeb,0);
      
    ELSE
       CLOSE cr_detalhe_ult_lanc;
    END IF;
    
    --> Extornar Abono
    IF vr_vldpagto > 0 AND 
       vr_vlest_abono > 0 THEN
      
     IF vr_vlest_abono < vr_vldpagto THEN
       vr_dscritic := 'Não possui valor de abono suficiente para estorno do pagamento.';
       RAISE vr_exc_erro;     
     END IF;
    
      --> Estorno na prejuizo detalhe
      BEGIN
        INSERT INTO tbcc_prejuizo_detalhe (
           dtmvtolt
          ,nrdconta
          ,cdhistor
          ,vllanmto
          ,dthrtran
          ,cdoperad
          ,cdcooper
          ,idprejuizo
          ,dsjustificativa
         )
         VALUES (
           rw_crapdat.dtmvtolt
          ,pr_nrdconta
          ,2724 -- ESTORNO - > Abono de prejuízo
          ,vr_vldpagto
          ,SYSDATE
          ,vr_cdoperad
          ,pr_cdcooper
          ,rw_detalhe_ult_lanc.idprejuizo
          ,pr_justific
         );
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro de insert na tbcc_prejuizo_detalhe(2724): '||SQLERRM;
          RAISE vr_exc_erro;
      END;                    
      
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                                to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
                                               '1;100;650009');

      vr_nrdocmto := 999992724; 
      LOOP
          
      LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       , pr_cdagenci => vr_cdagenci
                                       , pr_cdbccxlt => vr_nrdcaixa
                                       , pr_nrdolote => 650009
                                       , pr_nrdconta => pr_nrdconta
                                       , pr_nrdocmto => vr_nrdocmto
                                       , pr_cdhistor => 2724
                                       , pr_nrseqdig => vr_nrseqdig
                                       , pr_vllanmto => vr_vldpagto
                                       , pr_nrdctabb => pr_nrdconta
                                       , pr_cdpesqbb => 'ESTORNO DE ABONO DE PREJUÍZO DE C/C'
                                       , pr_dtrefere => rw_crapdat.dtmvtolt
                                       , pr_hrtransa => gene0002.fn_busca_time
                                       , pr_cdoperad => vr_cdoperad
                                       , pr_cdcooper => pr_cdcooper
                                       , pr_cdorigem => 5
                                       , pr_incrineg => vr_incrineg
                                       , pr_tab_retorno => vr_tab_retorno
                                       , pr_cdcritic => vr_cdcritic
                                       , pr_dscritic => vr_dscritic);
                                                                             
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
          IF vr_incrineg = 0 THEN
            IF vr_cdcritic = 92 THEN
              vr_nrdocmto := vr_nrdocmto + 10000;
              continue;
      END IF;
            RAISE vr_exc_erro;
          ELSE
            RAISE vr_exc_erro;
          END IF;
        END IF;
          
        EXIT;
        
      END LOOP;
      
      --> atualizar valor de abono com o valor que realmente conseguiu abonar
      vr_vlest_abono := vr_vldpagto;
      vr_vldpagto    := 0;
      
    END IF;   
     
        
        BEGIN
            UPDATE tbcc_prejuizo prj
                 SET prj.vlrabono = prj.vlrabono - nvl(vr_vlest_abono, 0)
                     , prj.vljur60_ctneg = prj.vljur60_ctneg + nvl(vr_vlest_jur60, 0)
                     , prj.vljuprej = prj.vljuprej + nvl(vr_vlest_jupre,0)
                     , prj.vlpgprej = prj.vlpgprej - (nvl(vr_vlest_princ,0) + nvl(vr_vlest_IOF,0))
                     , prj.vlsdprej = prj.vlsdprej + (nvl(vr_vlest_saldo,0))
             WHERE prj.idprejuizo = rw_detalhe_ult_lanc.idprejuizo;
        EXCEPTION
            WHEN OTHERS THEN
                vr_cdcritic := 0;
        vr_dscritic := 'Erro de update na TBCC_PREJUIZO: ' || SQLERRM;
        RAISE vr_exc_erro;
        END;

    COMMIT;

    pr_cdcritic := NULL;
    pr_dscritic := NULL;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_grava_estorno_preju --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_grava_estorno_preju;

  PROCEDURE pc_consulta_estorno_preju(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE --> Código da cooperativa
                                     ,pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE --> Conta do cooperado
                                     --> CAMPOS IN/OUT PADRÃO DA MENSAGERIA
                                     ,pr_xmllog   IN VARCHAR2                            --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                        --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                           --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType                  --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                           --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2)IS                        --> Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_consulta_estorno_preju
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Diego Simas
    Data     : Setembro/2018                          Ultima atualizacao: 16/10/2018

    Dados referentes ao programa:

    Frequencia : -----
    Objetivo   : Rotina para consultar o estorno de pagamento de prejuízo de conta corrente.
    
    Alterações : 16/10/2018 - Ajuste na rotina para realizar o estorno do abono na conta corrente do cooperado.
                              PRJ450-Regulatorio(Odirlei-AMcom)

    -------------------------------------------------------------------------------------------------------------*/

    -- CURSORES --

    --> Consultar estorno de pagamento de conta corrente em prejuizo
    CURSOR cr_estornos(pr_cdcooper tbcc_prejuizo_detalhe.cdcooper%TYPE,
                      pr_nrdconta tbcc_prejuizo_detalhe.nrdconta%TYPE)IS
     SELECT d.cdhistor codigo
           ,d.vllanmto valor
           ,to_char(d.dthrtran, 'DD/MM/YYYY') data
           ,to_char(d.dthrtran, 'HH24:MI:SS') hora
           ,d.cdoperad cdoperad
      FROM tbcc_prejuizo_detalhe d
     WHERE d.cdcooper = pr_cdcooper
       AND d.nrdconta = pr_nrdconta
       AND d.cdhistor IN (2722,2724)
  ORDER BY d.dthrtran DESC;
    rw_estornos cr_estornos%ROWTYPE;

    --> Consultar operador
    CURSOR cr_operador(pr_cdcooper crapope.cdcooper%TYPE,
                       pr_cdoperad crapope.cdoperad%TYPE)IS
    SELECT c.nmoperad
      FROM crapope c
     WHERE c.cdcooper = pr_cdcooper
       AND c.cdoperad = pr_cdoperad;
    rw_operador cr_operador%ROWTYPE;

    --Variaveis de Criticas
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_reto   VARCHAR2(3);
    vr_exc_saida  EXCEPTION;

    --Tabela de Erros
    vr_tab_erro   gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper   crapcop.cdcooper%TYPE;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

    --Variaveis Locais
    vr_qtregist   INTEGER := 0;
    vr_clob       CLOB;
    vr_xml_temp   VARCHAR2(32726) := '';
    tot_estorno   crapepr.vljurmes%TYPE;
    vr_inprejuz   BOOLEAN;
    rw_crapdat    btch0001.cr_crapdat%ROWTYPE;
    vr_contador INTEGER := 0;

    --Variaveis de Indice
    vr_index      PLS_INTEGER;

    --Variaveis de Excecoes
    vr_exc_ok     EXCEPTION;
    vr_exc_erro   EXCEPTION;

  BEGIN
    pr_des_erro := 'OK';

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'estornos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_estornos
     IN cr_estornos(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta) LOOP

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'estornos', pr_posicao  => 0, pr_tag_nova => 'estorno', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'estorno', pr_posicao  => vr_contador, pr_tag_nova => 'codigo'  , pr_tag_cont => rw_estornos.codigo,   pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'estorno', pr_posicao  => vr_contador, pr_tag_nova => 'valor'   , pr_tag_cont => rw_estornos.valor,    pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'estorno', pr_posicao  => vr_contador, pr_tag_nova => 'data'    , pr_tag_cont => rw_estornos.data,     pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'estorno', pr_posicao  => vr_contador, pr_tag_nova => 'hora'    , pr_tag_cont => rw_estornos.hora,     pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'estorno', pr_posicao  => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_estornos.cdoperad, pr_des_erro => vr_dscritic);

        OPEN cr_operador(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => rw_estornos.cdoperad);
        FETCH cr_operador INTO rw_operador;
        IF cr_operador%FOUND THEN
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'estorno', pr_posicao  => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_operador.nmoperad, pr_des_erro => vr_dscritic);
           CLOSE cr_operador;
        ELSE
           gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'estorno', pr_posicao  => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => 'OPERADOR INEXISTENTE', pr_des_erro => vr_dscritic);
           CLOSE cr_operador;
        END IF;

        vr_contador := vr_contador + 1;

    END LOOP;

    pr_cdcritic := NULL;
    pr_dscritic := NULL;


  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_estorno_preju --> '|| SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_consulta_estorno_preju;


  PROCEDURE pc_define_situacao_cc_prej(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE   --> Código da cooperativa
                                      ,pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE  --> Conta do cooperado
                                      ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                                          ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                      ) IS
  
    /* .............................................................................

     Programa: pc_define_situacao_cc_prej
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Fabio Adriano (AMcom)
     Data    : Novemmbro/2018.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia : sempre que for chamado
     Objetivo   : Define a situação da conta quando passada pra prejuizo
     Alteracoes :

     ..............................................................................*/
  BEGIN   
   declare
     --cursores
     -- Verifica se a conta já está marcada como "em preuízo"
     CURSOR cr_crapass  (pr_cdcooper  crapass.cdcooper%TYPE,
                         pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT a.inprejuz
           , a.cdsitdct
        FROM crapass a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta   = pr_nrdconta;
     rw_crapass  cr_crapass%ROWTYPE;
      
     -- Variável de críticas
      vr_cdcritic      integer;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_erro_transfprej EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      
  BEGIN
      
      -- consulta conta
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;    

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic:= 651;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;
     
      --Altera situacao da conta AQUI
      if rw_crapass.cdsitdct <> 2 then
        BEGIN
           UPDATE
             crapass
           SET
             crapass.CDSITDCT_ORIGINAL = rw_crapass.cdsitdct ,
             crapass.cdsitdct = 2
        WHERE
               crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
        EXCEPTION
           WHEN OTHERS THEN
              vr_dscritic := 'Erro ao alterar a situacao da conta para prejuizo: ' || SQLERRM;
           RAISE vr_erro_transfprej;
        END;
      end if;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      WHEN vr_erro_transfprej THEN
        -- Efetuar retorno do erro 
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao alterar a situacao da conta para prejuizo: ' ||SQLERRM; 
      
   END;   
  
  END pc_define_situacao_cc_prej;                                     


  PROCEDURE pc_tela_imprimir_relatorio(pr_nrdconta IN crapepr.nrdconta%TYPE        --> Numero da Conta
                                      ,pr_dtmvtolt IN VARCHAR2                     --> Data de Movimento
                                      ,pr_dtiniest IN VARCHAR2                     --> Data Inicio do Estorno
                                      ,pr_dtfinest IN VARCHAR2                     --> Data Fim do Estorno
                                                          --> CAMPOS IN/OUT PADRÃO DA MENSAGERIA
                                      ,pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                                      ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                                          ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                                          ,pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                                      ,pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                                        ,pr_des_erro OUT VARCHAR2) IS                --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_imprimir_relatorio
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Diego Simas (AMcom)
     Data    : Setembro/2018.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia : -----
     Objetivo   : Imprimir o relatorio de estornos de pagamento de prejuizo de conta corrente.
     Alteracoes :

     ..............................................................................*/
   DECLARE

      -- Cursor dos estornos de prejuizo de conta corrente
      CURSOR cr_estorno(pr_cdcooper IN tbepr_estorno.cdcooper%TYPE,
                        pr_nrdconta IN tbepr_estorno.nrdconta%TYPE,
                        pr_dtiniest IN tbepr_estorno.dtestorno%TYPE,
                        pr_dtfinest IN tbepr_estorno.dtestorno%TYPE) IS
      SELECT c.dtmvtolt
            ,c.nrdconta
            ,c.vllanmto
            ,c.cdoperad
            ,c.dsjustificativa
        FROM tbcc_prejuizo_detalhe c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.dtmvtolt BETWEEN pr_dtiniest AND pr_dtfinest
         AND c.cdhistor IN (2722,2724);
      rw_estorno cr_estorno%ROWTYPE;

      -- Cursor para encontrar o nome do PA
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT nmextage
        FROM crapage
       WHERE cdcooper = pr_cdcooper
         AND cdagenci = pr_cdagenci;
      vr_nmextage crapage.nmextage%TYPE;

      -- Cursor do Operador
      CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE,
                        pr_cdoperad crapope.cdoperad%TYPE) IS
        SELECT crapope.nmoperad
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
            vr_nmoperad crapope.nmoperad%TYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_des_reto      VARCHAR2(3);
      vr_typ_saida     VARCHAR2(3);

      vr_tab_erro      GENE0001.typ_tab_erro;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_xml_temp        VARCHAR2(32726) := '';
      vr_xml             CLOB;
      vr_nom_direto      VARCHAR2(500);
      vr_nmarqimp        VARCHAR2(100);
      vr_dtmvtolt        DATE;
      vr_dtiniest        DATE;
      vr_dtfinest        DATE;
      vr_bltemreg        BOOLEAN := FALSE;

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

      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/YYYY');
      vr_dtiniest := TO_DATE(pr_dtiniest,'DD/MM/YYYY');
      vr_dtfinest := TO_DATE(pr_dtfinest,'DD/MM/YYYY');

      -- Valida se a data Inicial e Final Foram preenchidas
      IF vr_dtiniest IS NULL THEN
        vr_dscritic := 'O campo data inicial nao foi preenchida';
        RAISE vr_exc_saida;
      END IF;

      IF vr_dtfinest IS NULL THEN
        vr_dscritic := 'O campo data final nao foi preenchida';
        RAISE vr_exc_saida;
      END IF;

      -- Monta documento XML
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Relatorio>
                                                      <Filtros>
                                                        <data_inicial>'||TO_CHAR(vr_dtiniest,'DD/MM/YYYY')||'</data_inicial>
                                                        <data_final>'||TO_CHAR(vr_dtfinest,'DD/MM/YYYY')||'</data_final>
                                                      </Filtros>');

      -- Percorre todos os lancamentos que foram estornados
      FOR rw_estorno IN cr_estorno(pr_cdcooper => vr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_dtiniest => vr_dtiniest,
                                   pr_dtfinest => vr_dtfinest) LOOP
          -- Possui registros
          vr_bltemreg := TRUE;

          -- Busca o nome da Agencia
          OPEN cr_crapage(pr_cdcooper => vr_cdcooper
                         ,pr_cdagenci => vr_cdagenci);
          FETCH cr_crapage INTO vr_nmextage;
          CLOSE cr_crapage;

          -- Busca o nome do Operador
          OPEN cr_crapope(vr_cdcooper, rw_estorno.cdoperad);
          FETCH cr_crapope INTO vr_nmoperad;
          CLOSE cr_crapope;

          gene0002.pc_escreve_xml(pr_xml            => vr_xml
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<Dados>
                                                          <nrdconta>'||rw_estorno.nrdconta||'</nrdconta>
                                                          <cdoperad>'||rw_estorno.cdoperad||'</cdoperad>
                                                          <dtestorno>'||TO_CHAR(rw_estorno.dtmvtolt,'DD/MM/YYYY')||'</dtestorno>
                                                          <vlpagmto>'||TO_CHAR(rw_estorno.vllanmto,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlpagmto>
                                                          <nmoperad>'||vr_nmoperad||'</nmoperad>
                                                          <dsjustificativa>'||rw_estorno.dsjustificativa||'</dsjustificativa>
                                                          <cdagenci>'||vr_cdagenci||'</cdagenci>
                                                          <nmextage>'||vr_nmextage||'</nmextage>
                                                        </Dados>');


      END LOOP; -- END FOR rw_estorno

      -- Caso nao possua registros
      IF NOT vr_bltemreg THEN
        vr_dscritic := 'Nenhum registro encontrado para os filtros informados';
        RAISE vr_exc_saida;
      END IF;

      -- Cria a Tag com os Totais
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Relatorio>'
                             ,pr_fecha_xml      => TRUE);

      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      -- Definir nome do relatorio
      vr_nmarqimp := 'crrl751_' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || '.pdf';

      -- Solicitar geração do relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper --> Cooperativa conectada
                                 ,pr_cdprogra  => 'ESTORN' --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/Relatorio/Dados' --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl751.jasper' --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto || '/' ||vr_nmarqimp --> Arquivo final com o path
                                 ,pr_cdrelato  => 751
                                 ,pr_qtcoluna  => 234 --> 80 colunas
                                 ,pr_flg_gerar => 'S' --> Geraçao na hora
                                 ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''  --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1   --> Número de cópias
                                 ,pr_sqcabrel  => 1   --> Qual a seq do cabrel
                                 ,pr_nrvergrl  => 1   --> Numero da Versao do Gerador de Relatorio - TIBCO
                                 ,pr_des_erro  => vr_dscritic); --> Saída com erro
      -- Tratar erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Enviar relatorio para intranet
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper --> Cooperativa conectada
                                  ,pr_cdagenci => vr_cdagenci --> Codigo da agencia para erros
                                  ,pr_nrdcaixa => vr_nrdcaixa --> Codigo do caixa para erros
                                  ,pr_nmarqpdf => vr_nom_direto || '/' ||vr_nmarqimp --> Arquivo PDF  a ser gerado
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
                           ,pr_des_comando => 'rm ' || vr_nom_direto || '/' ||vr_nmarqimp
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);

      -- Criar XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||vr_nmarqimp || '</nmarqpdf>');

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_imprimir_relatorio: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_tela_imprimir_relatorio;

END PREJ0003;
/
