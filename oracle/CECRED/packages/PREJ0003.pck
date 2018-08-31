CREATE OR REPLACE PACKAGE CECRED.PREJ0003 AS

/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao: 28/08/2018

   Dados referentes ao programa:

   Frequencia: Di�ria (sempre que chamada)
   Objetivo  : Move  C.C. para preju�zo

   Alteracoes: 27/06/2018 - P450 - Cria��o de procedure para consulta de saldos - pc_consulta_sld_cta_prj (Daniel/AMcom)
               27/06/2018 - P450 - Cria��o de procedure para efetuar lan�amentos - pc_gera_lcm_cta_prj (Daniel/AMcom)
               28/06/2018 - P450 - Cria��o de procedure para liquidar conta em prejuizo - pc_liquida_prejuizo_cc (Rangel/Amcom)
               13/07/2018 - P450 - Cria��o rotina para calcular juros de prejuizos - pc_calc_juro_remuneratorio
               18/07/2018  -P450 - Pagamento Prejuizo de Forma Autom�tica  - pc_paga_prejuizo_cc   (Rangel Decker/AMcom)
               06/08/2018 - 9318:Pagamento de Emprestimo   -pc_pagar_contrato_emprestimo   Rangel Decker (AMcom)
               28/08/2018 - Cria��o de rotina para trazer o registro para estorno de preju�zo de conta corrente
                            PJ 450 - Diego Simas (AMcom)

..............................................................................*/

 FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                 , pr_nrdconta craplcm.nrdconta%TYPE)
  RETURN BOOLEAN;

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

  FUNCTION fn_sld_cta_prj(pr_cdcooper   IN NUMBER --> C�digo da Cooperativa
                         ,pr_nrdconta   IN NUMBER --> N�mero da conta
                         ,pr_exclbloq   IN NUMBER DEFAULT 1) --> Flag que indica se devem ser exclu�dos (subtra�dos) do saldo os cr�ditos bloqueados (cheques ainda n�o compensados)
                          RETURN NUMBER;

  -- Retorna a soma dos valores pagos (abonados) do preju�zo de c/c no dia
  FUNCTION fn_valor_pago_conta_prej(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE
                                  , pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE
                                  , pr_dtmvtolt IN tbcc_prejuizo_detalhe.dtmvtolt%TYPE
                                  , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  , pr_dscritic OUT crapcri.dscritic%TYPE) RETURN NUMBER;

   PROCEDURE pc_consulta_sld_cta_prj(pr_cdcooper IN NUMBER             --> C�digo da Cooperativa
                                   ,pr_nrdconta IN NUMBER             --> N�mero da conta
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

    PROCEDURE pc_gera_lcm_cta_prj(pr_cdcooper  IN NUMBER             --> C�digo da Cooperativa
                                 ,pr_nrdconta  IN NUMBER             --> N�mero da conta
                                 ,pr_cdoperad  IN VARCHAR2           --> C�digo do Operador
                                 ,pr_vlrlanc   IN NUMBER             --> Valor do Lan�amento
                                 ,pr_xmllog    IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER       --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2          --> Descri��o da cr�tica
                                 ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);        --> Erros do processo

   PROCEDURE pc_gera_transf_cta_prj(pr_cdcooper IN NUMBER
                                , pr_nrdconta IN NUMBER
                                , pr_cdoperad IN VARCHAR2 DEFAULT '1'
                                , pr_vllanmto IN NUMBER
                                , pr_dtmvtolt IN DATE
                                , pr_versaldo IN INTEGER DEFAULT 1 -- Se deve validar o saldo dispon�vel
																, pr_atsldlib IN INTEGER DEFAULT 1 -- Se deve atualizar o saldo dispon�vel para opera��es na conta corrente (VLSLDLIB)
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE);

   PROCEDURE pc_gera_debt_cta_prj(pr_cdcooper  IN NUMBER                 --> C�digo da Cooperativa
                                 ,pr_nrdconta  IN NUMBER                --> N�mero da conta
                                 ,pr_cdoperad  IN VARCHAR2 DEFAULT '1'  --> C�digo do Operador
                                 ,pr_vlrlanc   IN NUMBER                --> Valor do Lan�amento
                                 ,pr_dtmvtolt  IN DATE                  --> Data da cooperativa
                                 ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2);        --> Erros do processo


  PROCEDURE pc_grava_prejuizo_cc(pr_cdcooper       IN crapcop.cdcooper%TYPE   --> Coop conectada
                                ,pr_nrdconta      IN  crapass.nrdconta%TYPE  --> NR da Conta
                                ,pr_tpope         IN VARCHAR2 DEFAULT 'N'    --> Tipo de Opera��o(N-Normal F-Fraude)
                                ,pr_cdcritic      OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                ,pr_dscritic      OUT VARCHAR2               --> Descri��o da Critica
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
                                      ,pr_dscritic       OUT VARCHAR2              -->Descri��o Critica
                                      ,pr_tab_erro       OUT gene0001.typ_tab_erro);

PROCEDURE pc_ret_saldo_dia_prej ( pr_cdcooper  IN crapcop.cdcooper%TYPE         --> Coop conectada
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE         --> Numero da conta
                                 ,pr_dtmvtolt  IN DATE                          --> Data incio do periodo do prejuizo
                                 ,pr_exclbloq  IN NUMBER DEFAULT 0              --> Se deve subtrair os cr�ditos bloqueados
                                 ,pr_vldsaldo OUT NUMBER                        --> Retorna valor do saldo
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE         --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2 );

  PROCEDURE pc_transf_cc_preju_fraude(pr_cdcooper   IN NUMBER             --> Cooperativa conectada
                                     ,pr_nrdconta   IN NUMBER             --> N�mero da conta
                                     ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER       --> C�digo da cr�tica
                                     ,pr_dscritic   OUT VARCHAR2          --> Descri��o da cr�tica
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
 PROCEDURE pc_pagar_IOF_conta_prej(pr_cdcooper  IN craplcm.cdcooper%TYPE        -- C�digo da Cooperativa
                                 ,pr_nrdconta  IN craplcm.nrdconta%TYPE        -- N�mero da Conta
                                 ,pr_vllanmto  IN craplcm.vllanmto%TYPE        -- Valor do Lan�amento
                                 ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE
                                 ,pr_vlbasiof  IN crapsld.vlbasiof%TYPE
                                 ,pr_idlautom  IN craplcm.idlautom%TYPE DEFAULT 0
                                 ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                 ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_devolve_chq_prej(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                               ,pr_dscritic OUT VARCHAR2
                               ,pr_tab_erro OUT gene0001.typ_tab_erro  );

  -- Debita os valores provisionados para os hist�ricos de juros +60 (37, 38 e 57)
  PROCEDURE pc_debita_juros60_prj(pr_cdcooper IN crapsld.cdcooper%TYPE   --> Coop conectada
                                 ,pr_nrdconta IN crapsld.nrdconta%TYPE   --> N�mero da conta
                                 ,pr_vlhist37 OUT NUMBER                 --> Valor debitador para o hist�rico 37
                                 ,pr_vlhist57 OUT NUMBER                 --> Valor debitador para o hist�rico 57
                                 ,pr_vlhist38 OUT NUMBER                 --> Valor debitador para o hist�rico 38
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


  PROCEDURE pc_pagar_contrato_emprestimo(pr_cdcooper  IN crapepr.cdcooper%TYPE       -- C�digo da Cooperativa
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE       -- N�mero da Conta
                                        ,pr_cdagenci  IN NUMBER                      -- C�digo da agencia
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE       -- N�mero do contrato de empr�stimo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                        ,pr_cdoperad  IN VARCHAR2                    -- C�digo do operador
                                        ,pr_vlrpagto  IN NUMBER                      -- Valor pago
                                        ,pr_vlrabono  IN NUMBER DEFAULT 0            -- Valor do abono concedido (aplicado somente a contratos em preju�zo)
                                        ,pr_idorigem  IN NUMBER                      -- Indicador da origem
                                        ,pr_idvlrmin OUT NUMBER                      -- Indica que houve critica do valor minimo
                                        ,pr_vltotpag OUT NUMBER                      -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                      -- C�digo de cr�ticia
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
                                   , pr_idprejuizo IN tbcc_prejuizo_detalhe.idprejuizo%TYPE
                                   , pr_vllanmto IN tbcc_prejuizo_detalhe.vllanmto%TYPE
                                   , pr_cdoperad IN tbcc_prejuizo_detalhe.cdoperad%TYPE DEFAULT '1'
                                   , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   , pr_dscritic OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_sld_cta_prj(pr_cdcooper IN NUMBER
                         , pr_nrdconta IN NUMBER
                         , pr_vlrsaldo OUT NUMBER
                         , pr_cdcritic OUT crapcri.cdcritic%TYPE
                         , pr_dscritic OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_busca_sit_bloq_preju(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                   ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

  PROCEDURE pc_cred_disp_prj(pr_cdcooper IN NUMBER
                           , pr_nrdconta IN NUMBER
                           , pr_vlrsaldo OUT NUMBER
                           , pr_cdcritic OUT crapcri.cdcritic%TYPE
                           , pr_dscritic OUT crapcri.dscritic%TYPE);


end PREJ0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0003 AS
/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   :Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Di�ria (sempre que chamada)
   Objetivo  : Transferencia do prejuizo de conta corrente

   Alteracoes: 27/06/2018 - P450 - Cria��o de procedure para consulta de saldos - pc_consulta_sld_cta_prj (Daniel/AMcom)
               27/06/2018 - P450 - Cria��o de procedure para efetuar lan�amentos - pc_gera_lcm_cta_prj (Daniel/AMcom)
               28/06/2018 - P450 - Conting�ncia para contas n�o transferidas para preju�zo - Diego Simas - AMcom
               18/07/2018  -P450 - Pagamento Prejuizo de Forma Autom�tica  - pc_paga_prejuizo_cc
..............................................................................*/

  -- clob para conter o dados do excel/csv
   vr_clobarq   CLOB;
   vr_texto_completo  VARCHAR2(32600);
   vr_mailprej  VARCHAR2(1000);

   -- C�digo do programa
   vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'PREJU';
   vr_exc_saida exception;

   vr_cdcritic  NUMBER(3);
   vr_dscritic  VARCHAR2(1000);


  -- Verifica se a conta est� em preju�zo
  FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                  , pr_nrdconta craplcm.nrdconta%TYPE)
    RETURN BOOLEAN AS vr_conta_em_prejuizo BOOLEAN;

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

  FUNCTION fn_sld_cta_prj(pr_cdcooper   IN NUMBER --> C�digo da Cooperativa
                         ,pr_nrdconta   IN NUMBER --> N�mero da conta
                         ,pr_exclbloq   IN NUMBER DEFAULT 1) --> Flag que indica se devem ser exclu�dos (subtra�dos) do saldo os cr�ditos bloqueados (cheques ainda n�o compensados)
                          RETURN NUMBER IS
  BEGIN

    /* .............................................................................

    Programa: fn_sld_conta_prejuizo
    Sistema : Ayllos
    Autor   : Daniel Silva - AMcom
    Data    : Junho/2018                 Ultima atualizacao:

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Retornar o saldo da contra transit�ria
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

      -- Calcula valor dos cr�ditos bloqueados (cheques n�o compensados)
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

      vr_sldtot      NUMBER := 0; --> Saldo total da conta transit�ria
      vr_crdblq      NUMBER; --> Cr�ditos bloqueados
    BEGIN
      -- Busca saldo total da conta transit�ria
      OPEN cr_sld;
      FETCH cr_sld INTO vr_sldtot;
      CLOSE cr_sld;

      -- Se deve excluir (subtrair) os cr�ditos bloqueados por cheques n�o compensados
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

  --Retorna o valor dos cr�ditos dispon�veis na CC em preju�zo
  FUNCTION fn_cred_disp_prj(pr_cdcooper IN crapris.cdcooper%TYPE
                          , pr_nrdconta IN crapris.nrdconta%TYPE) RETURN NUMBER IS

    -- Busca valor do saldo liberado para opera��es na CC
    CURSOR cr_sldlib IS
    SELECT vlsldlib
      FROM tbcc_prejuizo
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;

    vr_vlcreddisp NUMBER; -- Valor dos cr�ditos dispon�veis para uso no pagamento
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

  -- Retorna a soma dos valores pagos (abonados) do preju�zo de c/c no dia
  FUNCTION fn_valor_pago_conta_prej(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE
                                  , pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE
                                  , pr_dtmvtolt IN tbcc_prejuizo_detalhe.dtmvtolt%TYPE
                                  , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  , pr_dscritic OUT crapcri.dscritic%TYPE) RETURN NUMBER IS

    -- Recupera somat�rio dos lan�amentos de pagamento e abono do preju�zo de conta corrente
    CURSOR cr_pagamentos IS
    SELECT nvl(SUM(prj.vllanmto), 0) valor_pagamentos
      FROM tbcc_prejuizo_detalhe prj
     WHERE prj.cdcooper = pr_cdcooper
       AND prj.nrdconta = pr_nrdconta
       AND prj.dtmvtolt = pr_dtmvtolt
       AND prj.cdhistor IN (2723,2733);

    vr_valor_pagamentos NUMBER;
  BEGIN
    pr_cdcritic := 0;
    pr_dscritic := NULL;

    OPEN cr_pagamentos;
    FETCH cr_pagamentos INTO vr_valor_pagamentos;
    CLOSE cr_pagamentos;

    RETURN vr_valor_pagamentos;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro n�o tratado na rotina PREJ0003.fn_valor_pago_conta_prej: ' || SQLERRM;
  END fn_valor_pago_conta_prej;

  -- Subrotina para escrever texto na vari�vel CLOB do XML
  PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB,
                                pr_des_dados IN VARCHAR2,
                                pr_fecha_arq IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
     gene0002.pc_escreve_xml(pr_clobdado, vr_texto_completo, pr_des_dados, pr_fecha_arq);
  END;

  PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS
    /* .............................................................................

    Programa: pc_transfere_prejuizo_cc
    Sistema :
    Sigla   : PREJ
    Autor   : Rangel Decker  AMcom
    Data    : Maio/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua as transferencias de prejuizo de conta corrente.

    Alteracoes: 21/06/2018 - Popular a tabela TBCC_PREJUIZO quando a conta � transferida para preju�zo.
                            Quantidade de dias em atraso
                            Valor saldo preju�zo Rangel Decker (AMcom)

                28/06/2018 - P450 - Conting�ncia para contas n�o transferidas para preju�zo - Diego Simas - AMcom

    ..............................................................................*/

    --Busca contas correntes que est�o na situa��o de prejuizo
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
       AND   ris.innivris  = 9    -- Situa��o H
       AND  (pr_dtmvtolt - ris.dtdrisco) >= 180  -- dias_risco
       AND   ris.qtdiaatr >=180 -- dias_atraso
       AND   NOT EXISTS (SELECT 1
                           FROM crapepr epr
                          WHERE epr.cdcooper = ris.cdcooper
                            AND epr.nrdconta = ris.nrdconta
                            AND epr.inprejuz = 1
                            AND epr.cdlcremp = 100)
       AND NOT EXISTS (SELECT 1
                         FROM crapcyc cyc
                        WHERE cyc.cdcooper = ris.cdcooper
                          AND cyc.nrdconta = ris.nrdconta
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
      -- Leitura do calend�rio da cooperativa
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
          -- Utilizar o final do m�s como data
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
             --Montar cabe�alho arquivo csv
             dbms_lob.createtemporary(vr_clobarq, TRUE, dbms_lob.CALL);
             dbms_lob.open(vr_clobarq, dbms_lob.lob_readwrite);

             pc_escreve_clob(vr_clobarq,'Cooperativa; Conta; Risco; Dias no Risco; Dias de atraso; Motivo'||chr(13));


            END IF;
             vr_possui_erro:=TRUE;
            -- ASSUNTO: Aten��o! Houve erro na transfer�ncia para preju�zo.
            -- EMAIL: recuperacaodecredito@cecred.coop.br
            -- ARQUIVO ANEXO DEVE CONTER: cooperativa, conta, risco, dias no risco,
            --                            dias de atraso e motivo pelo qual a conta
            --                            n�o foi transferida.
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

    -- Se houve erros de transfer�ncia e necessita enviar o e-mail de conting�ncia
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
                                ,pr_tpope         IN VARCHAR2 DEFAULT 'N'    --> Tipo de Opera��o(N-Normal F-Fraude)
                                ,pr_cdcritic      OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                ,pr_dscritic      OUT VARCHAR2               --> Descri��o da Critica
                                ,pr_des_erro      OUT VARCHAR2) IS

    -- Verifica se a conta j� est� marcada como "em preu�zo"
    CURSOR cr_crapass  (pr_cdcooper  crapass.cdcooper%TYPE,
                        pr_nrdconta  crapass.nrdconta%TYPE) IS
     SELECT a.inprejuz
          , a.vllimcre
          , a.cdsitdct
       FROM crapass a
      WHERE a.cdcooper = pr_cdcooper
        AND a.nrdconta   = pr_nrdconta;
    rw_crapass  cr_crapass%ROWTYPE;

		-- Verifica se h� registro com motivo de a��o judicial na CRAPCYC
		CURSOR cr_crapcyc(pr_cdcooper crapass.cdcooper%TYPE
		                , pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT 1
			  FROM crapcyc cyc
			 WHERE cyc.cdcooper = pr_cdcooper
				 AND cyc.nrdconta = pr_nrdconta
				 AND cyc.cdmotcin = 2;

    --Busca contas correntes que est�o na situa��o de prejuizo
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
       AND   ris.nrdconta  not in (SELECT epr.nrdconta
                                   FROM   crapepr epr
                                   WHERE epr.cdcooper = ris.cdcooper
                                   AND   epr.nrdconta = ris.nrdconta
                                   AND   epr.inprejuz = 1
                                   AND   epr.cdlcremp = 100)
       AND  ris.nrdconta  not in   (SELECT cyc.nrdconta
                                    FROM   crapcyc cyc
                                    WHERE cyc.cdcooper = ris.cdcooper
                                    AND   cyc.nrdconta = ris.nrdconta
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

    --Variavel de exce��o
    vr_exc_saida exception;

    --Data da cooperativa
    rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

    --Variaveis para lan�amentos de d�bito
    vr_rw_craplot  LANC0001.cr_craplot%ROWTYPE;
    vr_tab_retorno LANC0001.typ_reg_retorno; -- REcord com dados retornados pela "pc_gerar_lancamento_conta"
    vr_incrineg   PLS_INTEGER;

    --Tipo da tabela de saldos
    vr_tab_saldo EXTR0001.typ_tab_saldos;

    -- Vari�veis para busca do saldo devedor
    vr_vlslddev  NUMBER:= 0;
    vr_dtrefere_aux  DATE;
    vr_tab_erro cecred.gene0001.typ_tab_erro;

    vr_qtdiaatr crapris.qtdiaatr%TYPE;

    -- Valores de juros +60
    vr_vlhist37 NUMBER;
    vr_vlhist38 NUMBER;
    vr_vlhist57 NUMBER;

    vr_vljuro60_cneg NUMBER; -- Juros +60 (Hist. 37 + Hist. 57)
    vr_vljuro60_cesp NUMBER; -- Juros +60 (Hist. 38)

    vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
		vr_existecyc INTEGER;
  BEGIN
      pr_des_erro:='OK';

      -- Leitura do calend�rio da cooperativa
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

      --Verificar se est� executando no primeiro dia �til do m�s
      IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
          -- Utiliza o dia da �ltima mensal como data
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

     -- Verifica se a conta est� marcada como "em preju�zo" (para o caso de transfer�ncia for�ada)
     IF rw_crapass.inprejuz = 1 THEN
       vr_cdcritic := 0;
       vr_dscritic := 'A conta informada j� est� marcada como "Em preju�zo".';

       RAISE vr_exc_saida;
     END IF;

		 IF pr_tpope <> 'N' THEN
			 OPEN cr_crapcyc(pr_cdcooper, pr_nrdconta);
			 FETCH cr_crapcyc INTO vr_existecyc;

			 IF cr_crapcyc%FOUND THEN
				 CLOSE cr_crapcyc;

				  vr_cdcritic := 0;
          vr_dscritic := 'A conta encontra-se marcada como "Determina��o Judicial" na CADCYB.';

          RAISE vr_exc_saida;
			 END IF;

			 CLOSE cr_crapcyc;
		 END IF;

     -- Cancela produtos/servi�os da conta (cart�o magn�tico, senha da internet, limite de cr�dito)
     pc_cancela_servicos_cc_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtinc_prejuizo => rw_crapdat.dtmvtolt
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

     IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic <> NULL THEN
       vr_cdcritic:= 0;
       vr_dscritic:= 'Erro ao cancelar produtos/servi�os para a conta ' || pr_nrdconta;

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

     IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic <> NULL THEN
       vr_cdcritic:= 0;
       vr_dscritic:= 'Erro ao debitar valores provisionados de juros +60 para conta ' || pr_nrdconta;

       RAISE vr_exc_saida;
     END IF;

     -- Busca saldo devedor (saldo at� 59 dias de atraso) e juros +60 n�o pagos da conta
     TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60_det(pr_cdcooper => pr_cdcooper
                                                   , pr_nrdconta => pr_nrdconta
                                                   , pr_vlsld59d => vr_vlslddev
                                                   , pr_vljucneg => vr_vljuro60_cneg
                                                   , pr_vljucesp => vr_vljuro60_cesp
                                                   , pr_cdcritic => vr_cdcritic
                                                   , pr_dscritic => vr_dscritic);

     IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic <> NULL THEN
       vr_cdcritic:= 0;
       vr_dscritic:= 'Erro ao recuperar saldo devedor da conta corrente ' || pr_nrdconta;

       RAISE vr_exc_saida;
     END IF;

     IF pr_tpope = 'N' THEN -- Transfer�ncia normal (180 dias de atraso e 180 dias no risco H)
       -- Busca dados da conta na central de risco
       OPEN cr_crapris( pr_cdcooper      => pr_cdcooper
                       ,pr_nrdconta      => pr_nrdconta
                       ,pr_dtrefere      => vr_dtrefere_aux
                       ,pr_dtmvtolt      => rw_crapdat.dtmvtolt);
       FETCH cr_crapris INTO rw_crapris;

       IF cr_crapris%NOTFOUND THEN
         CLOSE cr_crapris;

         vr_cdcritic:= 0;
         vr_dscritic:='Conta n�o atende �s regras de transfer�ncia para preju�zo.';

         RAISE vr_exc_saida;
       ELSE
         CLOSE cr_crapris;

         vr_qtdiaatr := rw_crapris.qtdiaatr;
       END IF;
     ELSE -- Transfer�ncia por fraude (for�ada)
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
               vr_vlslddev + vr_vljuro60_cneg + vr_vljuro60_cesp,
               vr_qtdiaatr,
               vr_vlslddev,
               vr_vljuro60_cneg,
               vr_vljuro60_cesp,
               CASE WHEN pr_tpope = 'N' THEN 0 ELSE 1 END)
       RETURNING idprejuizo INTO vr_idprejuizo;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:=0;
          vr_dscritic := 'Erro de insert na TBCC_PREJUIZO: '||SQLERRM;
        RAISE vr_exc_saida;
     END;

     BEGIN
       UPDATE crapass pass
          SET pass.cdsitdct = 2, -- 2-Em Prejuizo
              pass.inprejuz = 1
        WHERE pass.cdcooper = pr_cdcooper
          AND pass.nrdconta = pr_nrdconta;
     EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:=0;
          vr_dscritic := 'Erro de update na CRAPASS: '||SQLERRM;
        RAISE vr_exc_saida;
     END;

     -- Registra as informa��es da transfer�ncia no extrato do preju�zo
     pc_lanca_transf_extrato_prj(pr_idprejuizo => vr_idprejuizo
                               , pr_cdcooper   => pr_cdcooper
                               , pr_nrdconta   => pr_nrdconta
                               , pr_vlsldprj   => vr_vlslddev
                               , pr_vljur60_ctneg => vr_vljuro60_cneg
                               , pr_vljur60_lcred => vr_vljuro60_cesp
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


   --Numero de contrato de limite de credito ativo
   CURSOR cr_craplim (pr_cdcooper craplim.cdcooper%TYPE,
                        pr_nrdconta craplim.nrdconta%TYPE   ) IS
      SELECT  lim.nrctrlim
      FROM craplim lim
      WHERE lim.cdcooper = pr_cdcooper
      AND   lim.nrdconta = pr_nrdconta
      AND   lim.insitlim = 2;
    rw_craplim  cr_craplim%ROWTYPE;

    --Cart�es magneticos ativos
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
                                             ,pr_cdagenci => 0                          --Ag�ncia
                                             ,pr_nrdcaixa => 0                          --Caixa
                                             ,pr_cdoperad => '1'                        --Operador
                                             ,pr_nmdatela => 'PC_CANCELAR_SENHA_INTERNET' --Nome da tela
                                             ,pr_idorigem => 1                          --Origem
                                             ,pr_nrdconta => pr_nrdconta                --Conta
                                             ,pr_idseqttl => 1                          --Sequ�ncia do titular
                                             ,pr_dtmvtolt => pr_dtinc_prejuizo          --Data de movimento
                                             ,pr_inconfir => 3                          --Controle de confirma��o
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
           -- Se n�o encontrar
           IF cr_craplim%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craplim;
           ELSE
             --Cancelamento Limite de Credito
           LIMI0002.pc_cancela_limite_credito(pr_cdcooper   => pr_cdcooper                -- Cooperativa
                                               ,pr_cdagenci   => 0                          -- Ag�ncia
                                               ,pr_nrdcaixa   => 0                          -- Caixa
                                               ,pr_cdoperad   => '1'                        -- Operador
                                               ,pr_nrdconta   => pr_nrdconta                -- Conta do associado
                                               ,pr_nrctrlim   => rw_craplim.nrctrlim          -- Contrato de Rating
                                               ,pr_inadimp    => 1                          -- 1-Inadimpl�ncia 0-Normal
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
           -- Se n�o encontrar

           IF cr_crapcrm%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapcrm;
           ELSE
               -- Bloqueio cart�o magnetico
               cada0004.pc_bloquear_cartao_magnetico( pr_cdcooper => pr_cdcooper, --> Codigo da cooperativa
                                                      pr_cdagenci => 0,  --> Codigo de agencia
                                                      pr_nrdcaixa => 0, --> Numero do caixa
                                                      pr_cdoperad => '1',  --> Codigo do operador
                                                      pr_nmdatela => 'ATENDA', --> Nome da tela
                                                      pr_idorigem => 1,               --> Identificado de origem
                                                      pr_nrdconta => pr_nrdconta,  --> Numero da conta
                                                      pr_idseqttl => 1,  --> sequencial do titular
                                                      pr_dtmvtolt => pr_dtinc_prejuizo,              --> Data do movimento
                                                      pr_nrcartao => rw_crapcrm.nrcartao, --> Numero do cart�o
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
                                      ,pr_dscritic       OUT VARCHAR2              -->Descri��o Critica
                                      ,pr_tab_erro       OUT gene0001.typ_tab_erro) IS
    -- diretorio de geracao do relatorio
     vr_nom_direto  VARCHAR2(100);
     vr_nmarqimp  VARCHAR2(50);
  BEGIN

    -- Diego Simas (AMcom) Conting�ncia para a n�o transfer�ncia de preju�zo
    -- Se por algum erro de processamento n�o houve transfer�ncia de preju�zo
    -- Cria arquivo com as contas para mandar por email para a recupera��o de cr�dito
    -- Email: recuperacaodecredito@cecred.coop.br
    -- IN�CIO

    -- Busca do diret�rio base da cooperativa para CSV
     vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper); --> Utilizaremos o rl


     vr_mailprej := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => pr_cdcooper, pr_cdacesso => 'EMAIL_TESTE' );
    --gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => pr_cdcooper, pr_cdacesso => 'PREJ0003_EMAILS_PREJU' );

     vr_nmarqimp := 'PREJU_'||replace(pr_dtmvtolt,'/','')||'.csv';

     -- Submeter a gera��o do arquivo txt puro
     --Solicitar geracao do arquivo fisico

     GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper       --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra               --> Programa chamador
                                       ,pr_dtmvtolt  => pr_dtmvtolt               --> Data do movimento atual
                                       ,pr_dsxml     => pr_clobarq                --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_nom_direto||'/arq/'||vr_nmarqimp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                        --> Chamar a impress�o (Imprim.p)
                                       ,pr_flg_gerar => 'S'                        --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'S'                        --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                          --> N�mero de c�pias para impress�o
                                       ,pr_dspathcop => vr_nom_direto||'/salvar/'  --> Lista sep. por ';' de diret�rios a copiar o arquivo
                                       ,pr_dsmailcop => vr_mailprej                --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail =>'Atencao! Houve erro na '
                                                       ||'transferencia para prejuizo'--> Assunto do e-mail que enviar� o arquivo
                                       ,pr_dscormail =>  '<p><b>Em anexo a este '     --> HTML corpo do email que enviar� o arquivo
                                          ||'e-mail, segue a lista de contas que'
                                          ||' nao foram transferidas para'
                                          ||' prejuizo</b></p>'
                                       ,pr_fldosmail => 'S'                        --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_des_erro  => vr_dscritic);              --> Retorno de Erro



    -- Liberando a mem�ria alocada pro CLOB
    dbms_lob.close(vr_clobarq);
    dbms_lob.freetemporary(vr_clobarq);
    -- Testar se houve erro
    IF  pr_dscritic IS NOT NULL THEN
      -- Gerar exce��o
      RAISE vr_exc_saida;
    END IF;

    -- FIM
    -- Diego Simas (AMcom) Conting�ncia para a n�o transfer�ncia de preju�zo


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro n�o tratado
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
    Data    : Junho/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  :Altera��o do Tipo de Conta em preju�zo liquidado

    Alteracoes:
    ..............................................................................*/

  -- Recupera informa��es dos preju�zo a serem liquidados (saldo devedor total igual a zero)
  CURSOR cr_conta_liquida (pr_cdooper  IN tbcc_prejuizo.cdcooper%TYPE) IS
   SELECT tbprj.nrdconta,
          tbprj.cdsitdct_original,
          tbprj.rowid
     FROM tbcc_prejuizo tbprj
    WHERE tbprj.cdcooper = pr_cdcooper
      AND tbprj.dtliquidacao IS NULL
      AND (tbprj.vlsdprej +
           tbprj.vljuprej +
           tbprj.vljur60_ctneg +
           tbprj.vljur60_lcred) = 0;

  vr_cdcritic  NUMBER(3);
  vr_dscritic  VARCHAR2(1000);
  vr_des_erro  VARCHAR2(1000);
  vr_exc_saida exception;
  vr_sldconta NUMBER;

  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
 BEGIN
   -- Recupera calend�rio de datas da cooperativa
   OPEN BTCH0001.cr_crapdat(pr_cdcooper);
   FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
   CLOSE BTCH0001.cr_crapdat;

    -- Percorre a lista dos preju�zos que devem ser liquidados
    FOR rw_conta_liquida IN cr_conta_liquida(pr_cdcooper) LOOP
      BEGIN
        -- Restaura a situa��o da conta corrente e retira a flag de "em preju�zo"
        UPDATE crapass a
           SET a.inprejuz = 0,
               a.cdsitdct = rw_conta_liquida.cdsitdct_original
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = rw_conta_liquida.nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic :=99999;
          vr_dscritic := 'Erro ao atualizar a tabela CRAPASS. '||SQLERRM;

          -- ********** TROCAR POR gera_log *******************
          RAISE vr_exc_saida;
      END;

      -- Obt�m o saldo total da conta transit�ria
      vr_sldconta:= fn_sld_cta_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => rw_conta_liquida.nrdconta
                                  ,pr_exclbloq => 0);

      IF vr_sldconta > 0 THEN
        -- Gera lan�amento para transfer�ncia do saldo dispon�vel da conta transit�ria para a conta corrente
        pc_gera_transf_cta_prj(pr_cdcooper  => pr_cdcooper               --> C�digo da Cooperativa
                           ,pr_nrdconta => rw_conta_liquida.nrdconta --> N�mero da conta
                           ,pr_cdoperad => 1                         --> C�digo do Operador
                           ,pr_vllanmto => vr_sldconta               --> Valor do Lan�amento
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_versaldo => 0                         --> N�o valida o saldo dispon�vel
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

        IF nvl(vr_cdcritic, 0) <> 0 OR vr_dscritic IS NOT NULL THEN
           -- ********** TROCAR POR gera_log *******************
           RAISE vr_exc_saida;
        END IF;
      END IF;

      BEGIN
        -- Zero o saldo dispon�vel para opera��es na conta corrente
        UPDATE tbcc_prejuizo tbprj
           SET tbprj.vlsldlib     = 0
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

    EXCEPTION
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic ||SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
 END  pc_liquida_prejuizo_cc;

  PROCEDURE pc_consulta_sld_cta_prj(pr_cdcooper IN NUMBER             --> C�digo da Cooperativa
                                   ,pr_nrdconta IN NUMBER             --> N�mero da conta
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
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
        Objetivo  : Rotina para consultar saldo de conta em Preju�zo
        Observacao: -----
        Alteracoes:
      ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    BEGIN
      pr_des_erro := 'OK';

      -- PASSA OS DADOS PARA O XML RETORNO
      -- Criar cabe�alho do XML
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
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro n�o tratado na rotina PREJ0003.pc_consulta_sld_cta_prj: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_consulta_sld_cta_prj;

PROCEDURE pc_gera_lcm_cta_prj(pr_cdcooper  IN NUMBER             --> C�digo da Cooperativa
                             ,pr_nrdconta  IN NUMBER             --> N�mero da conta
                             ,pr_cdoperad  IN VARCHAR2           --> C�digo do Operador
                             ,pr_vlrlanc   IN NUMBER             --> Valor do Lan�amento
                             ,pr_xmllog    IN VARCHAR2           --> XML com informa��es de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER       --> C�digo da cr�tica
                             ,pr_dscritic  OUT VARCHAR2          --> Descri��o da cr�tica
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
        Objetivo  : Rotina para efetuar lan�amento em conta Preju�zo
        Observacao: -----
        Alteracoes:
      ..............................................................................*/

      ----------->>> VARIAVEIS <<<--------
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
      vr_dscritic crapcri.dscritic%TYPE; --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
      pr_des_erro := 'OK';

      OPEN BTCH0001.cr_crapdat(pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Efetua a transfer�ncia da conta transit�ria para a conta corrente
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
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro n�o tratado na rotina PREJ0003.pr_gera_lcm_cta_prj: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_gera_lcm_cta_prj;

  PROCEDURE pc_gera_transf_cta_prj(pr_cdcooper IN NUMBER
                                , pr_nrdconta IN NUMBER
                                , pr_cdoperad IN VARCHAR2 DEFAULT '1'
                                , pr_vllanmto IN NUMBER
                                , pr_dtmvtolt IN DATE
                                , pr_versaldo IN INTEGER DEFAULT 1 -- Se deve validar o saldo dispon�vel
																, pr_atsldlib IN INTEGER DEFAULT 1 -- Se deve atualizar o saldo dispon�vel para opera��es na conta corrente (VLSLDLIB)
                                , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                , pr_dscritic OUT crapcri.dscritic%TYPE) IS

      vr_incrineg      INTEGER; --> Indicador de cr�tica de neg�cio para uso com a "pc_gerar_lancamento_conta"
      vr_tab_retorno   LANC0001.typ_reg_retorno;
      vr_nrseqdig     NUMBER     := 0;
      vr_nrdocmto     NUMBER(25) := 0;
      vr_nrdocmto_prj NUMBER(25) := 0;

      vr_exc_saida EXCEPTION;
  BEGIN
      pr_cdcritic := 0;
      pr_dscritic := NULL;

      -- Verifica se h� saldo dispon�vel para a transfer�ncia
      IF pr_versaldo = 1 AND pr_vllanmto > fn_sld_cta_prj(pr_cdcooper => pr_cdcooper
                                                        , pr_nrdconta => pr_nrdconta
                                                        , pr_exclbloq => 1) THEN

        vr_cdcritic := 0;
        vr_dscritic := 'Erro: Saldo insuficiente para a transfer�ncia do valor.';

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
        vr_dscritic := 'Erro ao buscar n�mero do documento na CRAPLCM';

        RAISE vr_exc_saida;
      END;

      -- Cria lan�amento de d�bito na conta transit�ria (TBCC_PREJUIZO_LANCAMENTO)
      pc_gera_debt_cta_prj(pr_cdcooper => pr_cdcooper
                         , pr_nrdconta => pr_nrdconta
                         , pr_cdoperad => pr_cdoperad
                         , pr_vlrlanc =>  pr_vllanmto
                         , pr_dtmvtolt => pr_dtmvtolt
                         , pr_cdcritic => vr_cdcritic
                         , pr_dscritic => vr_dscritic);

      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        IF vr_incrineg = 0 THEN
          RAISE vr_exc_saida;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir lan�amento (LANC0001)';

          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Gera valor do campo "nrseqdig" a partir da sequence (para n�o usar CRAPLOT)
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(pr_dtmvtolt, 'DD/MM/RRRR') ||';'||
                                '1;100;650010');

      -- Efetua lancamento de cr�dito na CRAPLCM(LANC0001)
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
        IF vr_incrineg = 0 THEN
          RAISE vr_exc_saida;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir lan�amento (LANC0001)';

          RAISE vr_exc_saida;
        END IF;
      END IF;

      IF pr_atsldlib = 1 THEN
				-- Atualiza o valor do saldo dispon�vel para opera��es na C/C
				UPDATE tbcc_prejuizo
					 SET vlsldlib = vlsldlib + pr_vllanmto
				 WHERE cdcooper = pr_cdcooper
					 AND nrdconta = pr_nrdconta
					 AND dtliquidacao IS NULL;
			END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_cdcritic := vr_cdcritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_dscritic;
      pr_dscritic := vr_dscritic;
  END pc_gera_transf_cta_prj;

  PROCEDURE pc_gera_debt_cta_prj(pr_cdcooper  IN NUMBER                 --> C�digo da Cooperativa
                                 ,pr_nrdconta  IN NUMBER                --> N�mero da conta
                                 ,pr_cdoperad  IN VARCHAR2 DEFAULT '1'  --> C�digo do Operador
                                 ,pr_vlrlanc   IN NUMBER                --> Valor do Lan�amento
                                 ,pr_dtmvtolt  IN DATE                  --> Data da cooperativa
                                 ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2) IS         --> Descri��o da cr�tica

/* .............................................................................

        Programa: pc_gera_lcm_cta_prj
        Sistema : CECRED
        Sigla   : PREJ
        Autor   : Rangel Decker/AMcom
        Data    : Julho/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para efetuar lan�amento de debito em conta Preju�zo
        Observacao: -----
        Alteracoes:
      ..............................................................................*/


      -- Outras
      vr_saldodisp    NUMBER     := 0;
      vr_nrseqdig     NUMBER     := 0;
      vr_nrdocmto     NUMBER(25) := 0;
      vr_nrdocmto_prj NUMBER(25) := 0;
      vr_cdhistor     NUMBER(5);
  BEGIN
      -- Consiste saldo com valor do par�metro
      vr_saldodisp := fn_sld_cta_prj(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_exclbloq => 1); --> Desconta cr�ditos bloqueados

      vr_cdhistor := 2739; -- D�bito da conta transit�ria (desbloqueio de valor)

/*
      IF vr_saldodisp < pr_vlrlanc THEN
        vr_cdcritic := 0;
        vr_dscritic := 'A conta' || pr_nrdconta || ' n�o possui saldo para esta opera��o!';

        RAISE vr_exc_saida;
      END IF;
      */

      -- Buscar Documento TBCC_PREJUIZO_LANCAMENTO
        BEGIN
          SELECT nvl(MAX(t.nrdocmto)+1, 1)
            INTO vr_nrdocmto_prj
            FROM tbcc_prejuizo_lancamento t
           WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.cdhistor = vr_cdhistor

             AND t.dtmvtolt = pr_dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro Buscar Documento TBCC_PREJUIZO_LANCAMENTO';
          RAISE vr_exc_saida;
        END;

      -- Efetua lancamento de d�bito na contra transit�ria
      BEGIN
        INSERT INTO tbcc_prejuizo_lancamento(dtmvtolt
                                            ,cdagenci
                                            ,nrdconta
                                            ,cdhistor
                                            ,nrdocmto
                                            ,vllanmto
                                            ,dthrtran
                                            ,cdoperad
                                            ,cdcooper)
                                      VALUES(pr_dtmvtolt  -- dtmvtolt
                                            ,1                -- cdagenci
                                            ,pr_nrdconta       -- nrdconta
                                            ,vr_cdhistor      -- cdhistor
                                            ,vr_nrdocmto_prj  -- nrdocmto
                                            ,pr_vlrlanc       -- vllanmto
                                            ,SYSDATE  -- dthrtran
                                            ,pr_cdoperad     -- cdoperad
                                            ,pr_cdcooper);    -- cooperativa
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro de insert na TBCC_PREJUIZO_LANCAMENTO:'||SQLERRM;
          RAISE vr_exc_saida;
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
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina PREJ0003.pc_gera_debt_cta_prj: ' || SQLERRM;
END pc_gera_debt_cta_prj;

PROCEDURE pc_ret_saldo_dia_prej ( pr_cdcooper  IN crapcop.cdcooper%TYPE         --> Coop conectada
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE         --> Numero da conta
                                 ,pr_dtmvtolt  IN DATE                          --> Data incio do periodo do prejuizo
                                 ,pr_exclbloq  IN NUMBER DEFAULT 0              --> Se deve subtrair os cr�ditos bloqueados
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

    Objetivo  : Retornar saldo do dia do prejuizo

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
    -- Leitura do calend�rio da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
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

    IF pr_dtmvtolt = rw_crapdat.dtmvtolt THEN
      vr_vldsaldo  := prej0003.fn_sld_cta_prj(pr_cdcooper => pr_cdcooper,
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

        vr_dscritic := 'N�o h� saldo para o dia ' || to_char(pr_dtmvtolt,'DD/MM/RRRR');

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
      -- Efetuar retorno do erro n�o tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao obter o saldo: ' || SQLERRM;
  END pc_ret_saldo_dia_prej;
  --
  PROCEDURE pc_transf_cc_preju_fraude(pr_cdcooper   IN NUMBER             --> Cooperativa conectada
                                     ,pr_nrdconta   IN NUMBER             --> N�mero da conta
                                     ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER       --> C�digo da cr�tica
                                     ,pr_dscritic   OUT VARCHAR2          --> Descri��o da cr�tica
                                     ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2) is      --> Erros do processo

    /* .............................................................................
    Programa: pc_transf_cc_preju_fraude
    Sistema :
    Sigla   : PREJ
    Autor   : Heckmann - AMcom
    Data    : Julho/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Transferir a conta corrente fraude para preju�zo

    Alteracoes:

    ..............................................................................*/

    ----------->>> VARIAVEIS <<<--------
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    vr_desmsg  varchar2(1000);         --> Utilizada para informar se a transa��o funcionou ou n�o

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posi��o no XML

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nrdrowid ROWID;

    ---->> CURSORES <<-----

  begin

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

    -- Se retornou alguma cr�tica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exce��o
      RAISE vr_exc_saida;
    END IF;

    begin
      pr_des_erro := 'OK';
      vr_desmsg   := 'Transferido a conta corrente fraude para preju�zo';

      -- Realiza a transfer�ncia da CC para preju�zo
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
      vr_desmsg   := 'Erro ao transferir a conta corrente fraude para preju�zo! ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';

      rollback;
    end;


      -- PASSA OS DADOS PARA O XML RETORNO
      -- Criar cabe�alho do XML
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
                          ,pr_dstransa => 'Transferido a conta corrente para preju�zo'
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
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  end pc_transf_cc_preju_fraude;
  --

  PROCEDURE pc_calc_juro_prejuizo_mensal (pr_cdcooper IN NUMBER
                                        , pr_cdcritic    OUT crapcri.cdcritic%TYPE
                                        , pr_dscritic    OUT crapcri.dscritic%TYPE) IS

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
     -- Carrega o calend�rio de datas da cooperativa
     OPEN BTCH0001.cr_crapdat(pr_cdcooper);
     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     CLOSE BTCH0001.cr_crapdat;

     -- Percorre as contas em preju�zo da cooperativa
     FOR rw_contas IN cr_contas LOOP
        -- Executa o c�lculo dos juros remunerat�rios
        prej0003.pc_calc_juro_remuneratorio(pr_cdcooper => rw_contas.cdcooper,
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

           -- Gera valor do campo "nrseqdig" a partir da sequence (para n�o usar CRAPLOT)
           vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(SYSDATE, 'DD/MM/RRRR')||';'||
                                '1;100;650011');

           -- Debita os juros remunerat�rios na conta corrente
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
        pr_dscritic := 'Erro calc. Juro preju�zo mensal: ' || SQLERRM;
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

    Objetivo  : Calcular juros para prejuizos

    Alteracoes:
*/
       vr_exc_saida EXCEPTION;

       -- Recupera as informa��es do preju�zo de conta corrente
       CURSOR cr_tbcc_prejuizo IS
       SELECT a.dtinclusao
            , a.dtrefjur
            , a.vlsdprej +
              a.vljur60_ctneg +
              a.vljur60_lcred +
              a.vljuprej vlsdprej
         FROM tbcc_prejuizo a
        WHERE a.idprejuizo = pr_idprejuizo;
       rw_tbcc_prejuizo cr_tbcc_prejuizo%ROWTYPE;

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

     OPEN cr_tbcc_prejuizo;

     IF cr_tbcc_prejuizo%NOTFOUND THEN
        pr_des_reto := 'N�o h� preju�zo ativo para a conta informada: ' || pr_idprejuizo;

        CLOSE cr_tbcc_prejuizo;

        RAISE vr_exc_saida;
     ELSE
        FETCH cr_tbcc_prejuizo INTO rw_tbcc_prejuizo;
     END IF;

     CLOSE cr_tbcc_prejuizo;

     vr_dtdpagto := to_char(pr_dtdpagto,'DD');

     if rw_tbcc_prejuizo.dtrefjur is null then
        vr_diarefju := to_char(rw_tbcc_prejuizo.dtinclusao,'DD');
        vr_mesrefju := to_char(rw_tbcc_prejuizo.dtinclusao,'MM');
        vr_anorefju := to_char(rw_tbcc_prejuizo.dtinclusao,'RRRR');
     else
        vr_diarefju := to_char(rw_tbcc_prejuizo.dtrefjur,'DD');
        vr_mesrefju := to_char(rw_tbcc_prejuizo.dtrefjur,'MM');
        vr_anorefju := to_char(rw_tbcc_prejuizo.dtrefjur,'RRRR');
     end if;

     vr_diafinal := to_char(pr_dtdpagto,'DD');
     vr_mesfinal := to_char(pr_dtdpagto,'MM');
     vr_anofinal := to_char(pr_dtdpagto,'RRRR');

     -- Calcula a quantidade de dias a ser considerada para o c�lculo dos juros remunerat�rios
     empr0001.pc_calc_dias360(pr_ehmensal => pr_ehmensal,
                              pr_dtdpagto => vr_dtdpagto,
                              pr_diarefju => vr_diarefju,
                              pr_mesrefju => vr_mesrefju,
                              pr_anorefju => vr_anorefju,
                              pr_diafinal => vr_diafinal,
                              pr_mesfinal => vr_mesfinal,
                              pr_anofinal => vr_anofinal,
                              pr_qtdedias => vr_qtdedias);

     -- Buscar dados da TAB para extra��o da taxa de juros remunerat�rios
     vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'PAREMPREST'
                                              ,pr_tpregist => 01);

     -- Extrai a taxa de juros remunerat�rios cadastrada na tela TAB089
     vr_pctaxpre := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,121,6)),0);

     --Calcular Juros
     vr_valor    := 1 + (vr_pctaxpre / 100);
     vr_potencia := POWER(vr_valor, vr_qtdedias);

     --Retornar Juros calculados
     pr_vljpreju := rw_tbcc_prejuizo.vlsdprej * (vr_potencia - 1);

     --Se valor for  negativo
     IF pr_vljpreju < 0 THEN
        --zerar Valor
        pr_vljpreju := 0;
        --Sair
        RAISE vr_exc_saida;
     END IF;

     pr_diarefju := vr_diarefju;
     pr_mesrefju := vr_mesrefju;
     pr_anorefju := vr_anorefju;
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
     vr_dscritic := 'A conta informada n�o se encontra em preju�zo.';

     CLOSE cr_tbcc_prejuizo;

     RAISE vr_exc_saida;
   END IF;

   CLOSE cr_tbcc_prejuizo;

   -- Calcula os juros remunerat�rios desde a �ltima data de pagamento/d�bito at� o dia atual
    vr_diarefju  := nvl(rw_tbcc_prejuizo.nrdiarefju, to_char(rw_tbcc_prejuizo.dtinclusao, 'DD'));
    vr_mesrefju  := nvl(rw_tbcc_prejuizo.nrmesrefju, to_char(rw_tbcc_prejuizo.dtinclusao, 'MM'));
    vr_anorefju  := nvl(rw_tbcc_prejuizo.nranorefju, to_char(rw_tbcc_prejuizo.dtinclusao, 'YYYY'));

    prej0003.pc_calc_juro_remuneratorio(pr_cdcooper => pr_cdcooper,
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
     pr_dscritic := 'Erro n�o tratado na rotina PREJ0003.pc_calc_juros_remun_prov: ' || SQLERRM;
 END pc_calc_juros_remun_prov;

 PROCEDURE pc_pagar_prejuizo_cc(pr_cdcooper IN crapass.cdcooper%TYPE
                              , pr_nrdconta IN crapass.nrdconta%TYPE
                              , pr_vlrpagto IN craplcm.vllanmto%TYPE
                              , pr_vlrabono IN craplcm.vllanmto%TYPE DEFAULT NULL
                              , pr_cdcritic OUT crapcri.cdcritic%TYPE
                              , pr_dscritic OUT crapcri.dscritic%TYPE) IS
   /* .............................................................................

  Programa: pc_pagar_prejuizo_cc
  Sistema : AYLLOS
  Sigla   : PREJ
  Autor   : Reginaldo (AMcom)
  Data    : Agosto/2018.                  Ultima atualizacao:

  Dados referentes ao programa:

  Frequencia: Di�ria (sempre que chamada)

  Objetivo : Efetua a o pagamento de preju�zo de uma conta espec�fica.

  Alteracoes:
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

  --Verifica se tem lan�amento futuro para IOF
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

  vr_tab_retorno LANC0001.typ_reg_retorno; -- Record com dados retornados pela "pc_gerar_lancamento_conta"
  vr_incrineg   PLS_INTEGER;

  vr_vljr60_ctneg  tbcc_prejuizo.vljur60_ctneg%TYPE  := 0; -- Valor pago de juros +60 (hist. 37 + hist. 57)
  vr_vljur60_lcred tbcc_prejuizo.vljur60_lcred%TYPE  := 0; -- Valor pago de juros +60 (hist. 38)
  vr_vljupre       tbcc_prejuizo.vljuprej%TYPE       := 0; -- Valor pago de juros remunerat�rios do preju�zo
  vr_vljupre_prov  tbcc_prejuizo.vljuprej%TYPE       := 0; -- Valor pago de juros remunerat�rios (provisionados) do preju�zo
  vr_vlprinc       tbcc_prejuizo.vlsdprej%TYPE       := 0; -- Valor pago do saldo devedor principal do preju�zo
  vr_nrseqdig      craplcm.nrseqdig%TYPE;

  vr_diarefju  number(2);
  vr_mesrefju  number(2);
  vr_anorefju  number(4);

  vr_des_erro VARCHAR2(2000);

	vr_exc_saida EXCEPTION;
 BEGIN
    pr_cdcritic := 0;
    pr_dscritic := NULL;

    -- Comp�e o saldo dispon�vel para pagamento com a soma do valor pago e do valor do abono concedido
    vr_vlsddisp := pr_vlrpagto + nvl(pr_vlrabono, 0);

    -- Leitura do calend�rio da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;

      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Recupera informa��es do preju�zo da conta
    OPEN cr_contaprej(pr_cdcooper, pr_nrdconta);
    FETCH cr_contaprej INTO rw_contaprej;
    CLOSE cr_contaprej;

     vr_vljr60_ctneg  := 0;
     vr_vljur60_lcred := 0;
     vr_vljupre       := 0;

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
        vr_vllanciof := vr_vllanciof -  vr_vlsddisp;  --Paga Parcial
      END IF;

      pc_pagar_IOF_conta_prej(pr_cdcooper   =>pr_cdcooper           -- C�digo da Cooperativa
                             ,pr_nrdconta   =>pr_nrdconta -- N�mero da Conta
                             ,pr_vllanmto   =>vr_vllanciof          -- Valor do Lan�amento
                             ,pr_dtmvtolt   =>rw_crapdat.dtmvtolt
                             ,pr_vlbasiof   =>rw_crapsldiof.vlbasiof
                             ,pr_cdcritic   => vr_cdcritic           -- C�digo de cr�ticia
                             ,pr_dscritic   => vr_dscritic );

        -- Se retornou erro
       IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
       END IF;

       -- Incluir lan�amento na TBCC_PREJUIZO_DETALHE
       -- IOF (Hist 2323)
       pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2323
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => vr_vllanciof
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

       -- Zera o valor do IOF provisionado na CRAPSLD
       UPDATE crapsld sld
          SET vliofmes = 0
            , vlbasiof = 0
        WHERE ROWID = rw_crapsldiof.rowid;
    END IF;

    --Calcula o saldo disponivel  apos pagamento de IOF
    vr_vlsddisp := vr_vlsddisp - nvl(vr_vllanciof,0);
    vr_valrpago := vr_valrpago + nvl(vr_vllanciof,0);

    vr_vllanciof := 0; -- Reinicializa a vari�vel para reutiliz�-la

    -- Verifica IOF no saldo da conta CRAPLAU (lan�amentos furutos)
    OPEN cr_craplauiof(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
    FETCH cr_craplauiof INTO rw_craplauiof;
    CLOSE cr_craplauiof;

    -- Conta possui saldo
    IF vr_vlsddisp > 0 AND nvl(rw_craplauiof.vliofmes,0) > 0 THEN
      IF vr_vlsddisp  >= rw_craplauiof.vliofmes THEN
         vr_vllanciof := rw_craplauiof.vliofmes;     -- Paga Total
      ELSE
        vr_vllanciof := vr_vllanciof -  vr_vlsddisp;  --Paga Parcial
      END IF;

      pc_pagar_IOF_conta_prej(pr_cdcooper   => pr_cdcooper           -- C�digo da Cooperativa
                             ,pr_nrdconta   => pr_nrdconta           -- N�mero da Conta
                             ,pr_vllanmto   => vr_vllanciof          -- Valor do Lan�amento
                             ,pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_vlbasiof   => rw_craplauiof.vlbasiof
                             ,pr_idlautom   => rw_craplauiof.idlancto
                             ,pr_cdcritic   => vr_cdcritic           -- C�digo de cr�ticia
                             ,pr_dscritic   => vr_dscritic );

        -- Se retornou erro
       IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
       END IF;

       -- Incluir lan�amento na TBCC_PREJUIZO_DETALHE
       -- IOF (Hist 2323)
       pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2323
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => vr_vllanciof
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

       -- Marca o lan�amento como "Efetivado"
       UPDATE craplau
          SET insitlau = 2
        WHERE ROWID = rw_craplauiof.rowid;
    END IF;

    --Calcula o saldo disponivel  apos pagamento de IOF
    vr_vlsddisp := vr_vlsddisp - nvl(vr_vllanciof,0);
    vr_valrpago := vr_valrpago + nvl(vr_vllanciof,0);

    IF vr_vlsddisp > 0 AND rw_contaprej.vljur60_ctneg > 0 THEN
       --O Saldo disponivel pode liquidar Juros60 37,57
       IF vr_vlsddisp >= rw_contaprej.vljur60_ctneg THEN
         vr_vljr60_ctneg := rw_contaprej.vljur60_ctneg;
       ELSE
         vr_vljr60_ctneg := vr_vlsddisp;
       END IF;

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

    vr_vlsddisp:= vr_vlsddisp - vr_vljr60_ctneg;
    vr_valrpago := vr_valrpago + vr_vljr60_ctneg;

    IF  vr_vlsddisp > 0 AND rw_contaprej.vljur60_lcred > 0 THEN
       --O Saldo disponivel pode liquidar Juros60 38
       IF vr_vlsddisp >= rw_contaprej.vljur60_lcred THEN
         vr_vljur60_lcred := rw_contaprej.vljur60_lcred;
       ELSE
         vr_vljur60_lcred := vr_vlsddisp;
       END IF;

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

    vr_vlsddisp := vr_vlsddisp - vr_vljur60_lcred;
    vr_valrpago := vr_valrpago + vr_vljur60_lcred;

    IF vr_vljr60_ctneg + vr_vljur60_lcred > 0 THEN
       -- Incluir lan�amento na TBCC_PREJUIZO_DETALHE
       -- Juros +60 (Hist 37 + Hist 57)
       pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2727
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => vr_vljr60_ctneg + vr_vljur60_lcred
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);
    END IF;

    IF  vr_vlsddisp > 0 AND rw_contaprej.vljuprej > 0 THEN
       IF vr_vlsddisp >= rw_contaprej.vljuprej THEN
          vr_vljupre :=  rw_contaprej.vljuprej;
       ELSE
          vr_vljupre :=  vr_vlsddisp;
       END IF;

       BEGIN
          UPDATE  TBCC_PREJUIZO tbprj
          SET   tbprj.vljuprej = tbprj.vljuprej - vr_vljupre
          WHERE tbprj.rowid = rw_contaprej.rowid;
        EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic:= 0;
             vr_dscritic := 'Erro ao atualizar valor de Juros Remunerat�rios - TBCC_PREJUIZO:'||SQLERRM;
           RAISE vr_exc_saida;
        END;
    END IF;

    vr_vlsddisp := vr_vlsddisp - vr_vljupre;
    vr_valrpago := vr_valrpago + vr_vljupre;

    IF vr_vlsddisp > 0 THEN
      -- Calcula os juros remunerat�rios desde a �ltima data de pagamento/d�bito at� o dia atual
      vr_diarefju  := rw_contaprej.nrdiarefju;
      vr_mesrefju  := rw_contaprej.nrmesrefju;
      vr_anorefju  := rw_contaprej.nranorefju;

      prej0003.pc_calc_juro_remuneratorio(pr_cdcooper => pr_cdcooper,
                                          pr_ehmensal => FALSE,
                                          pr_dtdpagto => rw_crapdat.dtmvtolt,
                                          pr_idprejuizo => rw_contaprej.idprejuizo,
                                          pr_vljpreju => vr_vljupre_prov,
                                          pr_diarefju => vr_diarefju,
                                          pr_mesrefju => vr_mesrefju,
                                          pr_anorefju => vr_anorefju,
                                          pr_des_reto => vr_dscritic);

      IF vr_vljupre > 0 THEN
        -- Atualiza juros remunerat�rios do preju�zo
        UPDATE tbcc_prejuizo prj
           SET prj.dtrefjur = rw_crapdat.dtmvtolt
             , prj.nrdiarefju = vr_diarefju
             , prj.nrmesrefju = vr_mesrefju
             , prj.nranorefju = vr_anorefju
             , prj.vljuprej   = prj.vljuprej + vr_vljupre_prov
           WHERE prj.idprejuizo = rw_contaprej.idprejuizo;

        -- Gera valor do campo "nrseqdig" a partir da sequence (para n�o usar CRAPLOT)
        vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
                                '1;100;650011');

        -- Debita os juros remunerat�rios na conta corrente
        LANC0001.pc_gerar_lancamento_conta( pr_cdagenci => 1
                                           , pr_cdbccxlt => 100
                                           , pr_nrdolote => 650011
                                           , pr_cdhistor => 2718 -- juros remunaratorio do prejuizo
                                           , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           , pr_nrdconta => pr_nrdconta
                                           , pr_nrdctabb => pr_nrdconta
                                           , pr_nrdctitg => GENE0002.FN_MASK(pr_nrdconta, '99999999')
                                           , pr_nrdocmto => 99992718
                                           , pr_vllanmto => vr_vljupre_prov
                                           , pr_nrseqdig => vr_nrseqdig
                                           , pr_cdcooper => pr_cdcooper
                                           , pr_tab_retorno => vr_tab_retorno
                                           , pr_incrineg => vr_incrineg
                                           , pr_cdcritic => vr_cdcritic
                                           , pr_dscritic => vr_dscritic
                                           );

        -- Verifica se pode pagar o valor total ou parcial dos juros
        IF vr_vlsddisp < vr_vljupre_prov THEN
          vr_vljupre_prov := vr_vlsddisp;
        END IF;

        -- Atualiza o valor dos juros remunerat�rios, descontando o valor pago
        UPDATE  TBCC_PREJUIZO tbprj
          SET   tbprj.vljuprej = tbprj.vljuprej - vr_vljupre_prov
          WHERE tbprj.rowid = rw_contaprej.rowid;
      END IF;
    END IF;

    IF vr_vljupre_prov + vr_vljupre > 0 THEN
       -- Incluir lan�amento na TBCC_PREJUIZO_DETALHE
       -- Juros remunerat�rios (Hist 2729)
       pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2729
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => vr_vljupre_prov + vr_vljupre
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);
    END IF;

    vr_vlsddisp := vr_vlsddisp - vr_vljupre_prov;
    vr_valrpago := vr_valrpago + vr_vljupre_prov;

    -- Pagar saldo do preju�zo
    IF vr_vlsddisp > 0 THEN
      IF vr_vlsddisp >= rw_contaprej.vlsdprej THEN
        vr_vlprinc := rw_contaprej.vlsdprej;
      ELSE
        vr_vlprinc := vr_vlsddisp;
      END IF;

      -- Valor pago do saldo devedor principal do preju�zo
      pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                             , pr_nrdconta => pr_nrdconta
                             , pr_dtmvtolt => rw_crapdat.dtmvtolt
                             , pr_cdhistor => 2725
                             , pr_idprejuizo => rw_contaprej.idprejuizo
                             , pr_vllanmto => vr_vlprinc
                             , pr_cdcritic => vr_cdcritic
                             , pr_dscritic => vr_dscritic);

      -- Atualiza o saldo devedor, descontando o valor pago
      UPDATE tbcc_prejuizo prj
         SET prj.vlsdprej = prj.vlsdprej - vr_vlprinc
       WHERE prj.rowid = rw_contaprej.rowid;
    END IF;

    vr_valrpago := vr_valrpago + vr_vlprinc;

    -- Lan�ar valor do abono no extrato do preju�zo
    IF nvl(pr_vlrabono, 0) > 0 THEN
      -- Valor do abono concedido no pagamento
      pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2723
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => pr_vlrabono
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

      -- Gera valor do campo "nrseqdig" a partir da sequence (para n�o usar CRAPLOT)
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') ||';'||
                                '1;100;650010');

      -- Efetua lancamento de cr�dito na CRAPLCM(LANC0001)
      LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdagenci => 1
                                        ,pr_cdbccxlt => 100
                                        ,pr_nrdolote => 650010
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdocmto => 999992723
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
        IF vr_incrineg = 0 THEN
          RAISE vr_exc_saida;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao creditar o abono do preju�zo na conta corrente.';

          RAISE vr_exc_saida;
        END IF;
      END IF;

      UPDATE tbcc_prejuizo
         SET vlrabono = nvl(vlrabono, 0) + pr_vlrabono
       WHERE ROWID = rw_contaprej.rowid;
    END IF;

    IF pr_vlrpagto > 0 THEN
      -- Lan�a d�bito referente ao pagamento do preju�zo
      pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2721
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => pr_vlrpagto
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);

      -- Lan�a cr�dito referente ao pagamento do preju�zo
      pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => pr_nrdconta
                              , pr_dtmvtolt => rw_crapdat.dtmvtolt
                              , pr_cdhistor => 2733
                              , pr_idprejuizo => rw_contaprej.idprejuizo
                              , pr_vllanmto => pr_vlrpagto
                              , pr_cdcritic => vr_cdcritic
                              , pr_dscritic => vr_dscritic);
    END IF;

    UPDATE tbcc_prejuizo
       SET vlpgprej = nvl(vlpgprej, 0) + vr_valrpago
     WHERE ROWID = rw_contaprej.rowid;

    -- Desconta o valor total do pagamento efetuado do saldo dispon�vel para opera��es na C/C
    pc_atualiza_sld_lib_prj(pr_cdcooper => pr_cdcooper
                          , pr_nrdconta => pr_nrdconta
                          , pr_vlrdebto => least(vr_valrpago, pr_vlrpagto)
                          , pr_cdcritic => vr_cdcritic
                          , pr_dscritic => vr_dscritic
                          , pr_des_erro => vr_des_erro);

 EXCEPTION
	 WHEN vr_exc_saida THEN
		 pr_cdcritic := 0;
		 pr_dscritic := vr_dscritic;
   WHEN OTHERS THEN
      -- Efetuar retorno do erro n�o tratado
      pr_cdcritic := 99999;
      pr_dscritic := 'Erro n�o tratado na rotina PREJ0003.pc_pagar_prejuizo_cc: ' ||SQLERRM;
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

Frequencia: Di�ria (sempre que chamada)

Objetivo  : Efetua a o pagamento de preju�zo de forma autom�tica.


Alteracoes:
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
     rw_prej cr_contaprej%ROWTYPE;

     vr_cdcritic  NUMBER(3);
     vr_dscritic  VARCHAR2(1000);
     vr_des_erro  VARCHAR2(1000);

     vr_exc_saida exception;

     vr_vlsddisp NUMBER;

--     vr_dtrefere_aux  DATE;
  BEGIN


       --Lista as contas em prejuizo
       FOR  rw_contaprej in cr_contaprej(pr_cdooper => pr_cdcooper) LOOP
         -- Obt�m saldo dispon�vel para pagamento
         vr_vlsddisp:=  fn_cred_disp_prj(pr_nrdconta => rw_contaprej.nrdconta,
                                         pr_cdcooper => rw_contaprej.cdcooper);

         IF vr_vlsddisp > 0 THEN

           pc_pagar_prejuizo_cc(pr_cdcooper => pr_cdcooper
                           , pr_nrdconta => rw_contaprej.nrdconta
                           , pr_vlrpagto => vr_vlsddisp
                           , pr_cdcritic => vr_cdcritic
                           , pr_dscritic => vr_dscritic);
         END IF;

         -- Tratar cr�ticas
       END LOOP;

      COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      -- Efetuar retorno do erro n�o tratado
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

PROCEDURE pc_pagar_IOF_conta_prej(pr_cdcooper  IN craplcm.cdcooper%TYPE        -- C�digo da Cooperativa
                                 ,pr_nrdconta  IN craplcm.nrdconta%TYPE        -- N�mero da Conta
                                 ,pr_vllanmto  IN craplcm.vllanmto%TYPE        -- Valor do Lan�amento
                                 ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE
                                 ,pr_vlbasiof  IN crapsld.vlbasiof%TYPE
                                 ,pr_idlautom  IN craplcm.idlautom%TYPE DEFAULT 0
                                 ,pr_cdcritic OUT NUMBER                       -- C�digo de cr�ticia
                                 ,pr_dscritic OUT VARCHAR2) IS                -- Descri��o da cr�tica

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
  -- Altera��o :
  --
  ---------------------------------------------------------------------------------------------------------------

    ---------------> CURSORES <-------------
    CURSOR cr_nrseqdig(pr_rowid ROWID) IS
    SELECT nrseqdig
      FROM craplcm
     WHERE ROWID = pr_rowid;

    -- VARI�VEIS
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

    vr_cdhistor     NUMBER; -- C�digo do hist�rico para o lan�amento
    vr_exc_saida exception;
  BEGIN
        BEGIN
           --Inserir lancamento retornando o valor do rowid e do lan�amento para uso posterior
           LANC0001.pc_gerar_lancamento_conta(  pr_cdcooper => pr_cdcooper
                                              , pr_dtmvtolt => pr_dtmvtolt
                                              , pr_cdagenci  => 1
                                              , pr_cdbccxlt => 100
                                              , pr_nrdolote => 8450
                                              , pr_nrdconta => pr_nrdconta
                                              , pr_nrdctabb => pr_nrdconta
                                              , pr_nrdctitg => to_char(pr_nrdconta,'fm00000000')
                                              , pr_nrdocmto => 99999323
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
            RAISE vr_exc_saida; -- RElan�a a exce��o para ser tratada fora do bloco BEGIN...END
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

    Objetivo  : Efetua o resgate (desbloqueio) autom�tico de cr�ditos bloqueados por preju�zo (conta transit�ria).


    Alteracoes:
    ..............................................................................*/
    --

    -- Busca as contas em preju�zo para a cooperativa
    CURSOR cr_crapass IS
    SELECT ass.nrdconta
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.inprejuz = 1;
    rw_crapass cr_crapass%ROWTYPE;

    -- Busca cr�ditos antigos (ocorridos antes de pr_dtrefere)
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
       AND his.indebcre = 'C'
     ORDER BY blq.dtmvtolt;
    rw_crdant cr_crdant%ROWTYPE;

    -- Calcula soma dos lan�amentos de cr�dito ocorridos ap�s pr_dtrefere
    -- para descontar do saldo atual da conta transit�ria (bloqueios por preju�zo)
    CURSOR cr_somacred(pr_nrdconta tbcc_prejuizo_lancamento.nrdconta%TYPE
                     , pr_dtrefere tbcc_prejuizo_lancamento.dtmvtolt%TYPE) IS
    SELECT SUM(blq.vllanmto) vlsoma
      FROM tbcc_prejuizo_lancamento blq
         , craphis his
     WHERE blq.cdcooper =  pr_cdcooper
       AND blq.nrdconta =  pr_nrdconta
       AND blq.dtmvtolt > pr_dtrefere
       AND his.cdcooper = blq.cdcooper
       AND his.indebcre = 'C';

    CURSOR cr_cyber(pr_nrdconta tbrecup_acordo.nrdconta%TYPE) IS
    SELECT a.nracordo
      FROM tbrecup_acordo a
         , tbrecup_acordo_contrato c
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND a.cdsituacao = 1
       AND c.nracordo = a.nracordo
       AND c.cdorigem = 1;

    -- Calend�rio de datas da cooperativa
    rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

    vr_vlsoma           NUMBER;   -- Soma dos cr�ditos ocorridos ap�s a data de refer�ncia
    vr_saldo_resgatar   NUMBER;   -- Valor do saldo dispon�vel na conta transit�ria que pode ser resgatado
    vr_valor_transferir NUMBER;   -- Valor a transferir relativo a cada lan�amento de cr�dito
    vr_dstextab craptab.dstextab%TYPE;
    vr_qtdictcc NUMBER  :=0;
    vr_dtrefere DATE;
    vr_nracordo NUMBER;
    vr_total_resgatado NUMBER := 0;
  BEGIN
      -- Buscar Par�metros da TAB089
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPREST'
                                               ,pr_tpregist => 01);

      -- Par�metro da quantidade de dias para resgate autom�tico dos cr�ditos
      vr_qtdictcc := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,128,3)),0);

      -- Recupera o calend�rio de datas da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Calcula a data de refer�ncia para os cr�ditos a resgatar
      vr_dtrefere := rw_crapdat.dtmvtolt - vr_qtdictcc;

      -- Percorre as contas em preju�zo da cooperativa
      FOR rw_crapass IN cr_crapass LOOP
          -- Verifica se h� acordo de cobran�a ativo para a conta
          OPEN cr_cyber(rw_crapass.nrdconta);
          FETCH cr_cyber INTO vr_nracordo;
          CLOSE cr_cyber;

          IF vr_nracordo IS NOT NULL THEN
            continue; -- N�o efetua os resgates de cr�ditos para contas com acordo ativo
          END IF;

          -- Valor total dos cr�ditos resgatados para a conta corrente
          vr_total_resgatado := 0;

          -- Obt�m a soma dos cr�ditos ocorridos ap�s a data de refer�ncia
          OPEN cr_somacred(rw_crapass.nrdconta, vr_dtrefere);
          FETCH cr_somacred INTO vr_vlsoma;
          CLOSE cr_somacred;

          -- Calcula o saldo dos cr�ditos a resgatar
          vr_saldo_resgatar := fn_sld_cta_prj(pr_cdcooper => pr_cdcooper
                                            , pr_nrdconta => rw_crapass.nrdconta
                                            , pr_exclbloq => 1);
          vr_saldo_resgatar := vr_saldo_resgatar - vr_vlsoma;

          -- Se n�o h� cr�ditos a resgatar, desconsidera a conta
          IF vr_saldo_resgatar = 0 THEN
            continue;
          END IF;

          FOR rw_crdant IN cr_crdant(rw_crapass.nrdconta, vr_dtrefere) LOOP
            IF vr_saldo_resgatar > rw_crdant.vllanmto THEN
               vr_valor_transferir := rw_crdant.vllanmto; -- resgata o valor total do lancto de cr�dito
            ELSE
               vr_valor_transferir := vr_saldo_resgatar; -- resgata parte do valor do lancto de cr�dito
            END IF;

            -- Transfere lan�amento da conta transit�ria para a conta corrente
            pc_gera_transf_cta_prj(pr_cdcooper => pr_cdcooper
                                 , pr_nrdconta => rw_crapass.nrdconta
                                 , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 , pr_vllanmto => vr_valor_transferir
                                 , pr_cdcritic => vr_cdcritic
                                 , pr_dscritic => vr_dscritic);

            IF vr_dscritic IS NULL THEN
              vr_total_resgatado := vr_total_resgatado + nvl(vr_valor_transferir,0);
              COMMIT;
            ELSE
              ROLLBACK;
            END IF;

            -- Atualiza saldo dispon�vel para resgate
            vr_saldo_resgatar := vr_saldo_resgatar - vr_valor_transferir;

            -- Se n�o h� mais saldo dispon�vel para resgate, ignora os lanctos de cr�dito restantes
            IF vr_saldo_resgatar = 0 THEN
               EXIT;
            END IF;
          END LOOP;

          -- Atualiza o saldo liberado para opera��es na conta corrente
          UPDATE tbcc_prejuizo
             SET vlsldlib = nvl(vlsldlib,0) + nvl(vr_total_resgatado,0)
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = rw_crapass.nrdconta
             AND dtliquidacao IS NULL;
          COMMIT;
      END LOOP;
 END pc_resgata_cred_bloq_preju;

  PROCEDURE pc_devolve_chq_prej(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                               ,pr_dscritic OUT VARCHAR2
                               ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS
    /* .............................................................................

    Programa: pc_devolve_chq_prej
    Sistema :
    Sigla   : PREJ
    Autor   : Anderson Heckmann  AMcom
    Data    : Julho/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Diariamente

    Objetivo  : Se existir devolu��o de cheques depositados, realizar d�bito na conta transit�ria de preju�zo.

    Alteracoes:

    ..............................................................................*/

    -- Cursor para buscar os cheques devolvidos no dia
    CURSOR cr_chqdev(pr_dtmvtolt DATE) IS
      SELECT dev.nrcheque
           , dev.nrdconta
           , dev.vlcheque
        FROM gncpdev dev
       WHERE dev.cdcooper = pr_cdcooper
         AND dev.dtmvtolt = pr_dtmvtolt;
    rw_chqdev cr_chqdev%ROWTYPE;

     -- Cursor para buscar as informa��es de dep�sito do cheque devoldido
    CURSOR cr_crapchd (pr_nrdconta IN crapchd.nrdconta%TYPE
                      ,pr_nrcheque IN crapchd.nrcheque%TYPE
                      ,pr_vlcheque IN crapchd.vlcheque%TYPE) IS
      SELECT * FROM (SELECT chd.nrdconta
           , chd.nrdocmto
           , chd.vlcheque
           , chd.dtmvtolt
        FROM crapchd chd
       WHERE chd.cdcooper = pr_cdcooper
         AND chd.nrdconta = pr_nrdconta
         AND chd.nrcheque = pr_nrcheque
         AND chd.vlcheque = pr_vlcheque
      ORDER BY dtmvtolt DESC)
      WHERE rownum = 1;
    rw_crapchd cr_crapchd%ROWTYPE;

    -- Verifica se h� lan�amento na TBCC_PREJUIZO_LANCAMENTO para um cheque devolvido
    CURSOR cr_chqprj(pr_cdcooper tbcc_prejuizo_lancamento.cdcooper%TYPE
                    ,pr_nrdconta tbcc_prejuizo_lancamento.nrdconta%TYPE
                    ,pr_dtmvtolt tbcc_prejuizo_lancamento.dtmvtolt%TYPE
                    ,pr_nrdocmto tbcc_prejuizo_lancamento.nrdocmto%TYPE) IS
     SELECT count(1)
       FROM tbcc_prejuizo_lancamento tb
      WHERE tb.cdcooper = pr_cdcooper
        AND tb.nrdconta = pr_nrdconta
        AND tb.dtmvtolt = pr_dtmvtolt
        AND tb.nrdocmto = pr_nrdocmto;

    -- Calend�rio de datas da cooperativa
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    vr_qtctpre INTEGER := 0;
  BEGIN
    -- Carrega o calend�rio de datas da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Leitura dos cheques devolvidos no dia
    FOR rw_chqdev IN cr_chqdev(rw_crapdat.dtmvtolt) LOOP
      -- Leitura das informa��es dos cheques devolvidos
      FOR rw_crapchd IN cr_crapchd(pr_nrdconta => rw_chqdev.nrdconta
                                  ,pr_nrcheque => rw_chqdev.nrcheque
                                  ,pr_vlcheque => rw_chqdev.vlcheque) LOOP

        -- Verifica se h� dep�sito na Conta Transit�ria (TBCC_PREJUIZO_LANCAMENTO) para o cheque em quest�o
        OPEN cr_chqprj(pr_cdcooper
                      ,rw_chqdev.nrdconta
                      ,rw_crapchd.dtmvtolt
                      ,rw_crapchd.nrdocmto);
        FETCH cr_chqprj INTO vr_qtctpre;
        CLOSE cr_chqprj;

        IF vr_qtctpre > 0 THEN
          prej0003.pc_gera_debt_cta_prj(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_chqdev.nrdconta
                                       ,pr_cdoperad => 1
                                       ,pr_vlrlanc  => rw_chqdev.vlcheque
                                       ,pr_dtmvtolt => TRUNC(SYSDATE)
                                       ,pr_cdcritic => pr_cdcritic
                                       ,pr_dscritic => pr_dscritic);
        END IF;
      END LOOP;
    END LOOP;
  END pc_devolve_chq_prej;

  PROCEDURE pc_debita_juros60_prj(pr_cdcooper IN crapsld.cdcooper%TYPE   --> Coop conectada
                                 ,pr_nrdconta IN crapsld.nrdconta%TYPE   --> N�mero da conta
                                 ,pr_vlhist37 OUT NUMBER                 --> Valor debitador para o hist�rico 37
                                 ,pr_vlhist57 OUT NUMBER                 --> Valor debitador para o hist�rico 57
                                 ,pr_vlhist38 OUT NUMBER                 --> Valor debitador para o hist�rico 38
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                 ,pr_dscritic OUT VARCHAR2) IS

     -- Busca valores para c�lculo dos juros +60
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

     -- Busca dados do contrato de limite de cr�dito
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

    -- Calend�rio de datas da cooperativa
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
    -- Define valor inicial dos par�metros de retorno
    pr_vlhist37 := 0;
    pr_vlhist57 := 0;
    pr_vlhist38 := 0;

    -- Carrega calend�rio de datas da cooperativa
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
                                          ,pr_nrdocmto => 99999937
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


        IF TO_CHAR(rw_crapdat.dtmvtolt,'mm') <> TO_CHAR(rw_crapdat.dtmvtoan,'mm') THEN -- Primeiro dia �til
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
                                          ,pr_nrdocmto => 99999938
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
                                          ,pr_nrdocmto => 99999957
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

      -- Zera campos na CRAPSLD para evitar novo d�bito (indevido) dos valores
      UPDATE crapsld  sld
         SET vlsmnmes = 0
           , vlsmnesp = 0
           , vlsmnblq = 0
           , vljurmes = pr_vlhist37
           , vljuresp = pr_vlhist38
           , vljursaq = pr_vlhist57
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
      pr_dscritic := 'Erro n�o tratado na PREJ0003.pc_debita_juros60_prj';
  END pc_debita_juros60_prj;

  -- Cria lan�amentos no Extrato do Preju�zo referentes a transfer�ncia da conta
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
      pr_dscritic := 'Erro n�o tratado na pc_lanca_trans_extrato_prj: ' || SQLERRM;
  END pc_lanca_transf_extrato_prj;

 PROCEDURE pc_pagar_contrato_emprestimo(pr_cdcooper  IN crapepr.cdcooper%TYPE       -- C�digo da Cooperativa
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE       -- N�mero da Conta
                                        ,pr_cdagenci  IN NUMBER                      -- C�digo da agencia
                                        ,pr_nrctremp  IN crapepr.nrctremp%TYPE       -- N�mero do contrato de empr�stimo
                                        ,pr_nrparcel  IN tbrecup_acordo_parcela.nrparcela%TYPE -- N�mero da parcela
                                        ,pr_cdoperad  IN VARCHAR2                    -- C�digo do operador
                                        ,pr_vlrpagto  IN NUMBER                      -- Valor pago
                                        ,pr_vlrabono  IN NUMBER DEFAULT 0            -- Valor do abono concedido (aplicado somente a contratos em preju�zo)
                                        ,pr_idorigem  IN NUMBER                      -- Indicador da origem
                                        ,pr_idvlrmin OUT NUMBER                      -- Indica que houve critica do valor minimo
                                        ,pr_vltotpag OUT NUMBER                      -- Retorno do valor pago
                                        ,pr_cdcritic OUT NUMBER                      -- C�digo de cr�ticia
                                        ,pr_dscritic OUT VARCHAR2) IS                -- Descri��o da cr�tica

    -- Buscar os dados do contrato atrelado ao acordo e que ser� pago
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

    -- VARI�VEIS
    vr_vlpagmto     NUMBER := pr_vlrpagto;
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
    -- Se n�o encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haver� raise
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

    -- Se o contrato n�o for encontrado
    IF cr_crapepr%NOTFOUND THEN
      -- Fecha o cursor
      CLOSE cr_crapepr;

      -- Deve retornar erro de execu��o
      vr_cdcritic := 0;
      vr_dscritic := 'Contrato '||TRIM(GENE0002.fn_mask_contrato(pr_nrctremp))||
                     ' do acordo n�o foi encontrado para a conta '||
                     TRIM(GENE0002.fn_mask_conta(pr_nrdconta))||'.';
      RAISE vr_exp_erro;
    END IF;

    -- Fecha o cursor
    CLOSE cr_crapepr;

    -- Verificar se o contrato j� est� LIQUIDADO   OU
    -- Se o contrato de PREJUIZO j� foi TOTALMENTE PAGO
    IF (rw_crapepr.inliquid = 1 AND rw_crapepr.inprejuz = 0)  OR
       (rw_crapepr.inprejuz = 1 AND rw_crapepr.vlsdprej <= 0) THEN
      pr_vltotpag := 0; -- Indicar que nenhum valor foi pago para este contrato
      RETURN; -- Retornar da rotina
    END IF;

    -- Inicializa o indicador
    pr_idvlrmin := 0;

    -- Pagamento de Prejuizo
    IF rw_crapepr.inprejuz = 1 THEN
      IF pr_vlrabono > 0 THEN
        pc_crps780_1(pr_cdcooper =>  pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => pr_nrctremp,
                      pr_vlpagmto => vr_vlpagmto,
                      pr_vldabono => pr_vlrabono,
                      pr_cdagenci => 1,
                      pr_cdoperad => pr_cdoperad,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

         IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
           RAISE vr_exp_erro;
         ELSE
           pr_vltotpag := vr_vlpagmto + pr_vlrabono;
         END IF;
      ELSE
        -- Realizar a chamada da rotina para pagamento de prejuizo
        EMPR9999.pc_pagar_emprestimo_prejuizo(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_crapdat  => rw_crapdat
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_tpemprst => rw_crapepr.tpemprst
                                    ,pr_vlprejuz => rw_crapepr.vlprejuz
                                    ,pr_vlsdprej => rw_crapepr.vlsdprej
                                    ,pr_vlsprjat => rw_crapepr.vlsprjat
                                    ,pr_vlpreemp => rw_crapepr.vlpreemp
                                    ,pr_vlttmupr => rw_crapepr.vlttmupr
                                    ,pr_vlpgmupr => rw_crapepr.vlpgmupr
                                    ,pr_vlttjmpr => rw_crapepr.vlttjmpr
                                    ,pr_vlpgjmpr => rw_crapepr.vlpgjmpr
                                    ,pr_nrparcel => pr_nrparcel
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_vlparcel => vr_vlpagmto
                                    ,pr_nmtelant => 'BLQPREJU'
                                    ,pr_vliofcpl => rw_crapepr.vliofcpl
                                    ,pr_vltotpag => pr_vltotpag -- Retorno do total pago
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
        -- Se retornar erro da rotina
        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
          RAISE vr_exp_erro;
        END IF;
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
        -- Pagar empr�stimo TR
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
        -- Pagar empr�stimo PP
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
          EMPR9999.pc_pagar_emprestimo_pos(pr_cdcooper => pr_cdcooper         -- C�digo da Cooperativa
                                           ,pr_nrdconta       => pr_nrdconta         -- N�mero da Conta
                                           ,pr_cdagenci       => pr_cdagenci         -- C�digo da agencia
                                           ,pr_crapdat        => rw_crapdat          -- Datas da cooperativa
                                           ,pr_nrctremp       => pr_nrctremp         -- N�mero do contrato de empr�stimo
                                           ,pr_cdlcremp       => rw_crapepr.cdlcremp
                                           ,pr_vlemprst       => rw_crapepr.vlemprst
                                           ,pr_txmensal       => rw_crapepr.txmensal
                                           ,pr_dtprivencto    => rw_crapepr.dtprivencto
                                           ,pr_vlsprojt       => rw_crapepr.vlsprojt
                                           ,pr_qttolar        => rw_crapepr.qttolatr
                                           ,pr_nrparcel       => pr_nrparcel               -- N�mero da parcela
                                           ,pr_vlsdeved       => rw_crapepr.vlsdeved       -- Valor do saldo devedor
                                           ,pr_vlsdevat       => rw_crapepr.vlsdevat       -- Valor anterior do saldo devedor
                                           ,pr_idorigem       => pr_idorigem               -- Indicador da origem
                                           ,pr_nmtelant       => 'BLQPREJU'                -- Nome da tela
                                           ,pr_cdoperad       => pr_cdoperad               -- C�digo do operador
                                           ,pr_idvlrmin       => pr_idvlrmin               -- Indica que houve critica do valor minimo
                                           ,pr_vltotpag       => pr_vltotpag               -- Retorno do valor pago
                                           ,pr_cdcritic       => vr_cdcritic                -- C�digo de cr�ticia                     -- C�digo de cr�ticia
                                           ,pr_dscritic       => vr_dscritic);                     -- Descri��o da cr�tica
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
      -- Deve retornar erro de execu��o
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Retornar total pago como zero
      pr_vltotpag := 0;
      -- Deve retornar erro de execu��o
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na PC_PAGAR_CONTRATO_EMPRESTIMO: '||SQLERRM;
  END pc_pagar_contrato_emprestimo;

  PROCEDURE pc_atualiza_sld_lib_prj(pr_cdcooper IN tbcc_prejuizo.cdcooper%TYPE
                                  , pr_nrdconta IN tbcc_prejuizo.nrdconta%TYPE
                                  , pr_vlrdebto IN tbcc_prejuizo.vlsldlib%TYPE
                                  , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  , pr_dscritic OUT crapcri.dscritic%TYPE
                                  , pr_des_erro OUT VARCHAR) IS

    -- Busca o saldo liberado para opera��es na C/C
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

    -- Se o valor do d�bito � maior que o saldo liberado para opera��es na C/C
    IF rw_sldlib.vlsldlib < pr_vlrdebto THEN
      vr_dscritic := 'Saldo liberado para opera��es menor que o valor do d�bito informado.';

      RAISE vr_exc_erro;
    END IF;

    BEGIN
      -- Atualiza o saldo liberado, debitando o valor informado
      UPDATE tbcc_prejuizo prj
         SET prj.vlsldlib = prj.vlsldlib - pr_vlrdebto
       WHERE ROWID = rw_sldlib.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar o saldo liberado para opera��es na C/C.';

        RAISE vr_exc_erro;
    END;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro n�o tratado na PREJ0003.pc_atualiza_sld_lib_prj: ' || SQLERRM;
       pr_des_erro := 'NOK';
  END pc_atualiza_sld_lib_prj;

  PROCEDURE pc_gera_lcto_extrato_prj(pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE
                                   , pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE
                                   , pr_dtmvtolt IN tbcc_prejuizo_detalhe.dtmvtolt%TYPE
                                   , pr_cdhistor IN tbcc_prejuizo_detalhe.cdhistor%TYPE
                                   , pr_idprejuizo IN tbcc_prejuizo_detalhe.idprejuizo%TYPE
                                   , pr_vllanmto IN tbcc_prejuizo_detalhe.vllanmto%TYPE
                                   , pr_cdoperad IN tbcc_prejuizo_detalhe.cdoperad%TYPE DEFAULT '1'
                                   , pr_cdcritic OUT crapcri.cdcritic%TYPE
                                   , pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    pr_cdcritic := 0;
    pr_dscritic := NULL;

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
      )
      VALUES (
        pr_dtmvtolt
       ,pr_nrdconta
       ,pr_cdhistor
       ,pr_vllanmto
       ,SYSDATE
       ,pr_cdoperad
       ,pr_cdcooper
       ,pr_idprejuizo
      );
    EXCEPTION
         WHEN OTHERS THEN
           pr_dscritic := 'Erro n�o tratado na PREJ0003.pc_gera_lcto_extrato_prj: ' || SQLERRM;
    END;
  END pc_gera_lcto_extrato_prj;

  PROCEDURE pc_sld_cta_prj(pr_cdcooper IN NUMBER
                         , pr_nrdconta IN NUMBER
                         , pr_vlrsaldo OUT NUMBER
                         , pr_cdcritic OUT crapcri.cdcritic%TYPE
                         , pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    pr_cdcritic := 0;
    pr_dscritic := NULL;

    pr_vlrsaldo := fn_sld_cta_prj(pr_cdcooper => pr_cdcooper
                                , pr_nrdconta => pr_nrdconta);
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro n�o tratado na pc_sld_conta_prj: ' || SQLERRM;
  END;

  PROCEDURE pc_busca_sit_bloq_preju(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                   ,pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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
  Objetivo  : Consulta situa��o da conta e se j� ouve alguma vez que a
              conta foi transferida para preju�zo.

  Altera��es:

  -------------------------------------------------------------------------------------------------------------*/

    -- CURSORES --

    --> Consultar se j� houve prejuizo nessa conta
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
    vr_inprejuz INTEGER := 0;
    vr_ocopreju VARCHAR2(1) := 'N';

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

    -- Se retornou alguma cr�tica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exce��o
      RAISE vr_exc_saida;
    END IF;

    -- PASSA OS DADOS PARA O XML RETORNO
    -- Criar cabe�alho do XML
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
      CLOSE cr_crapass;
      vr_inprejuz := rw_crapass.inprejuz;
    ELSE
      CLOSE cr_crapass;
    END IF;

    OPEN cr_prejuizo(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);

    FETCH cr_prejuizo INTO rw_prejuizo;

    IF cr_prejuizo%FOUND THEN
      CLOSE cr_prejuizo;
      vr_ocopreju := 'S';
    ELSE
      vr_ocopreju := 'N';
      CLOSE cr_prejuizo;
    END IF;

    pr_cdcritic := NULL;
    pr_dscritic := NULL;

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
      -- Retorno n�o OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_erro:= 'NOK';

      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_preju_cc --> '|| SQLERRM;

      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_busca_sit_bloq_preju;

  PROCEDURE pc_cred_disp_prj(pr_cdcooper IN NUMBER
                           , pr_nrdconta IN NUMBER
                           , pr_vlrsaldo OUT NUMBER
                           , pr_cdcritic OUT crapcri.cdcritic%TYPE
                           , pr_dscritic OUT crapcri.dscritic%TYPE) IS
    BEGIN
      pr_cdcritic := 0;
      pr_dscritic := NULL;

      pr_vlrsaldo := fn_cred_disp_prj(pr_cdcooper => pr_cdcooper
                                    , pr_nrdconta => pr_nrdconta);
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro n�o tratado na pc_cred_disp_prj: ' || SQLERRM;
  END;

END PREJ0003;
/
