CREATE OR REPLACE PACKAGE CECRED.PREJ0002_prj AS

/*..............................................................................

   Programa: PREJ0002_prj                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Cal�o - Mout�S
   Data    : Agosto/2017                      Ultima atualizacao: 05/08/2017

   Dados referentes ao programa:

   Frequencia: Di�ria (sempre que chamada)
   Objetivo  : Centralizar os procedimentos e funcoes referente aos processos de
               pagamentos (recupera��o) de prejuizos

   Alteracoes: 19/04/2018 - Removida atualizacao de lote que estava sendo feita indevidamente.
                            As rotinas chamadas para geracao dos lancamentos ja fazem a atualizacao.
                            Heitor (Mouts) - Prj 324

..............................................................................*/

   TYPE typ_reg_log IS
      RECORD(valor_old crapprm.dsvlrprm%TYPE
            ,valor_new crapprm.dsvlrprm%TYPE);

    /* Pl-Table que ira chave e valor dos registros da CRAPPRM */
   TYPE typ_reg_consulta_prm IS
      RECORD(dsvlrprm crapprm.dsvlrprm%TYPE);

   TYPE typ_log           IS TABLE OF typ_reg_log          INDEX BY BINARY_INTEGER;
   TYPE typ_verifica_log  IS TABLE OF typ_log              INDEX BY BINARY_INTEGER;
   TYPE typ_consulta_prm  IS TABLE OF typ_reg_consulta_prm INDEX BY BINARY_INTEGER;

    /* Realiza a grava��o dos parametros da transferencia para prejuizo informados na tela PARTRP */

     /* Rotina para estornar pagamento prejuizo*/
     PROCEDURE pc_estorno_pagamento(pr_cdcooper in number
                                   ,pr_cdagenci in number
                                   ,pr_nrdconta in number
                                   ,pr_nrctremp in number
                                   ,pr_dtmvtolt in DATE
                                   ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                   ,pr_tab_erro OUT gene0001.typ_tab_erro  );

     /* rotina executada pela tela Atenda para "for�ar" o envio de empr�stimos para preju�zo */
     PROCEDURE pc_pagamento_prejuizo_web (pr_nrdconta   IN VARCHAR2     --> Conta corrente
                                         ,pr_nrctremp   IN VARCHAR2     --> Contrato de emprestimo
                                         ,pr_vlpagmto   in varchar2     --> valor do pagamento
                                         ,pr_vldabono   in varchar2     --> valor de abono
                                         ,pr_xmllog     IN VARCHAR2     --> XML com informa��es de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER  --> C�digo da cr�tica
                                         ,pr_dscritic  OUT VARCHAR2     --> Descri��o da cr�tica
                                         ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2     --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);

     /* Rotina chamada pela Atenda para estornar (desfazer) o preju�zo */
     PROCEDURE pc_estorno_pagamento_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_nrctremp   IN VARCHAR2  -- contrato
                                        ,pr_dtmvtolt   in varchar2
                                        ,pr_idtipo     in varchar2
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informa��es de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2)  ;

     /* Rotina chamada pela Atenda para transferir prejuizos de CC */
    /* PROCEDURE pc_pagamento_prejuizo_CC_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informa��es de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);
     */
     PROCEDURE pc_consulta_pagamento_web(pr_dtpagto in varchar2
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
              						 		 			  ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
 				    	          	 		 			  ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
						    				         			,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
          			    									,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					              							,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
										              		,pr_des_erro OUT VARCHAR2);

    PROCEDURE pc_valores_contrato_web(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);

    FUNCTION fn_dias_atraso_emp(pr_cdcooper IN crapepr.cdcooper%TYPE,
                                pr_nrdconta IN crapepr.nrdconta%TYPE,
                                pr_nrctremp IN crapepr.nrctremp%TYPE) RETURN NUMBER;
end PREJ0002_prj;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0002_prj AS
/*..............................................................................

   Programa: PREJ0002_prj                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Cal�o - Mout�S
   Data    : Maio/2017                      Ultima atualizacao: 24/04/2018

   Dados referentes ao programa:

   Frequencia: Di�ria (sempre que chamada)
   Objetivo  : Centralizar os procedimentos e funcoes referente aos processos de
               pagamento de preju�zo

      /** ---------------- LEGENDA -----------------------
      Historicos Pagamentos:
      NA LEM
      2388 -> Valor Principal
      2473 -> Juros +60
      2389 -> Juros atualiza��o

      2390 -> Multa  atraso
      2475 -> Juros Mora
      2391 -> Abono
      NA C/C
      2701 -> Valor de Pagamento
      2317 -> IOF

      Estorno

      2392 -> EST.PAG.PREJ.PRINCIP.
      2474 -> EST PGT JUROS +60
      2393 -> EST.PAGTO.JUROS PREJ
      2394 -> EST.PGT MULTA ATRASO
      2476 -> EST.PGT JUROS MORA
      2395 -> ESTORNO ABONO PREJ.
      2702 -> Estorno de pagamento LEM

      *************************************************

      Alteracoes: 01/08/2018 - Ajuste para bloquear pagamento quando a conta est� em preju�zo
                              PJ 450 - Diego Simas - AMcom

..............................................................................*/

  vr_cdcritic             NUMBER(3);
  vr_dscritic             VARCHAR2(1000);
  vr_des_reto             VARCHAR2(10);
  vr_tab_erro             gene0001.typ_tab_erro ;

  gl_nrdolote             NUMBER;

  rw_crapdat              btch0001.cr_crapdat%rowtype;

  CURSOR cr_crapepr(pr_cdcooper in number
                  ,pr_nrdconta in number
                  ,pr_nrctremp in number) IS
    SELECT *
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;


  /* Rotina para estornar pagamento de  prejuizo PP, TR e CC */
  PROCEDURE pc_estorno_pagamento(pr_cdcooper IN number
                                ,pr_cdagenci in number
                                ,pr_nrdconta in number
                                ,pr_nrctremp in number
                                ,pr_dtmvtolt in DATE
                                ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
    /* .............................................................................

    Programa: pc_estorno_pagamento
    Sistema : AyllosWeb
    Sigla   : PREJ
    Autor   : Jean Cal�o - Mout�S
    Data    : Agosto/2017.                  Ultima atualizacao: 24/04/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua o estorno de pagamento de prejuizos de contratos PP e TR
    Observacao: Rotina chamada pela tela ESTPRJ

    Alteracoes: 24/04/2018 - Nova Regra para bloqueio de estorno realizado pela tela ESTPRJ
                (Rafael Monteiro - Mouts)
                18/05/2018 - Adicionar o tratamento para hist�rico 2701 e 2702
                                 (Rafael - Mouts)

    ..............................................................................*/

    -- Cursor principal da rotina de estorno
    CURSOR c_craplem (prc_cdcooper craplem.cdcooper%TYPE
                     ,prc_nrdconta craplem.nrdconta%TYPE
                     ,prc_nrctremp craplem.nrctremp%TYPE
                     ,prc_dtmvtolt  craplem.dtmvtolt%TYPE) IS
         select lem.dtmvtolt,
                lem.cdhistor,
                lem.cdcooper,
                lem.nrdconta,
                lem.nrctremp,
                lem.vllanmto,
                lem.cdagenci,
                lem.nrdocmto,
                lem.rowid
           from craplem lem
          where lem.cdcooper = prc_cdcooper
            and lem.nrdconta = prc_nrdconta
            and lem.nrctremp = prc_nrctremp
            and lem.dtmvtolt = prc_dtmvtolt -- ESTORNAR TUDO DO DIA
            and lem.cdhistor in (2701  -- Valor pagamento
                                ,2388  -- Valor Principal
                                ,2473  -- Juros +60
                                ,2389  -- Juros atualiza��o
                                ,2390  -- Multa  atraso
                                ,2475  -- Juros Mora
                                ,2391);-- Abono
    -- Buscar proximo Lote
    CURSOR c_busca_prx_lote(pr_dtmvtolt DATE
                           ,pr_cdcooper NUMBER
                           ,pr_cdagenci NUMBER) IS
      SELECT MAX(nrdolote) nrdolote
        FROM craplot
       WHERE craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdcooper = pr_cdcooper
         AND craplot.cdagenci = pr_cdagenci;

    -- Buscar Pagamentos na conta
    CURSOR c_craplcm (prc_cdcooper craplcm.cdcooper%TYPE,
                      prc_nrdconta craplcm.nrdconta%TYPE,
                      prc_dtmvtolt craplcm.dtmvtolt%TYPE,
                      prc_nrctremp craplem.nrctremp%type) IS
      SELECT t.vllanmto
        FROM craplcm t
       WHERE t.cdcooper = prc_cdcooper
         AND t.nrdconta = prc_nrdconta
         AND t.cdhistor = 2386 -- Pagamento na conta
         AND t.cdbccxlt = 100
         AND TO_NUMBER(trim(replace(t.cdpesqbb,'.',''))) = prc_nrctremp
         AND t.dtmvtolt = prc_dtmvtolt;

    -- Buscar os bens da proposta
    CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE,
                       pr_nrdconta IN crapbpr.nrdconta%TYPE,
                       pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
      SELECT COUNT(1) total
        FROM crapbpr
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctremp
         AND crapbpr.tpctrpro IN (90,99)
         AND crapbpr.cdsitgrv IN (0,2)
         AND crapbpr.flgbaixa = 1
         AND crapbpr.tpdbaixa = 'A';
    vr_existbpr PLS_INTEGER := 0;

    -- Buscar bens baixados
    CURSOR cr_crapbpr_baixado(pr_cdcooper IN crapbpr.cdcooper%TYPE,
                              pr_nrdconta IN crapbpr.nrdconta%TYPE,
                              pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
      SELECT COUNT(1) total
        FROM crapbpr
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctremp
         AND crapbpr.dtdbaixa = pr_dtmvtolt
         AND crapbpr.tpctrpro IN (90,99)
         AND crapbpr.cdsitgrv IN (1,4) -- Em processamento, Baixado
         AND crapbpr.flgbaixa = 1
         AND crapbpr.tpdbaixa = 'A'
         ;
    vr_existbpr_baixado PLS_INTEGER := 0;

    -- VARIAVEIS
    rw_crapdat     btch0001.cr_crapdat%rowtype;
    vr_erro        exception;
    vr_dscritic    varchar2(1000);
    vr_cdcritic    integer;
    vr_flgativo    integer;
    vr_nrdolote    number;
    vr_nrdrowid    rowid;
    dt_gerarlcm    DATE;
    vr_dsctajud    crapprm.dsvlrprm%TYPE;         --> Parametro de contas que nao podem debitar os emprestimos
    vr_dsctactrjud crapprm.dsvlrprm%TYPE := null; --> Parametro de contas e contratos espec�ficos que nao podem debitar os emprestimos SD#618307

  --
  BEGIN

    -- Buscar Calend�rio
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Buscar Contrato
    OPEN cr_crapepr(pr_cdcooper, pr_nrdconta, pr_nrctremp);
    FETCH cr_crapepr INTO rw_crapepr;
    CLOSE cr_crapepr;

    -- Buscar bens baixados
    OPEN cr_crapbpr_baixado(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp);
    FETCH cr_crapbpr_baixado
     INTO vr_existbpr_baixado;
    CLOSE cr_crapbpr_baixado;
    -- N�O PERMITIR ESTORNAR CASO HAJA BAIXA DE GRAVAME
    IF vr_existbpr_baixado > 0 THEN
      vr_cdcritic := 0;
      pr_des_reto := 'NOK';
      vr_dscritic := 'N�o � permitido estorno, existe baixa da aliena��o: ';
      raise vr_erro;
    END IF;

    IF nvl(rw_crapepr.inprejuz,0) = 0 THEN
      vr_dscritic := 'N�o � permitido estorno, empr�stimo n�o est� em preju�zo: ';
      raise vr_erro;
    END IF;
    --
    dt_gerarlcm := NULL;

    -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
    vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');

     -- Lista de contas e contratos espec�ficos que nao podem debitar os emprestimos (formato="(cta,ctr)") SD#618307
    vr_dsctactrjud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_cdacesso => 'CTA_CTR_ACAO_JUDICIAL');

    -- Condicao para verificar se permite incluir as linhas parametrizadas
    IF INSTR(',' || vr_dsctajud || ',',',' || pr_nrdconta || ',') > 0 THEN
      vr_dscritic := 'Aten��o! Estorno n�o permitido. Verifique situa��o da conta.';
      RAISE vr_erro;
    END IF;

    -- Condicao para verificar se permite incluir as linhas parametrizadas SD#618307
    IF INSTR(replace(vr_dsctactrjud,' '),'('||trim(to_char(pr_nrdconta))||','||trim(to_char(pr_nrctremp))||')') > 0 THEN
      vr_dscritic := 'Aten��o! Estorno n�o permitido. Verifique situa��o da conta.';
      RAISE vr_erro;
    END IF;

    -- Verifica se existe contrato de acordo ativo
    RECP0001.pc_verifica_acordo_ativo (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp
                                      ,pr_cdorigem => 3
                                      ,pr_flgativo => vr_flgativo
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
    IF vr_cdcritic > 0OR vr_dscritic IS NOT NULL THEN
      raise vr_erro;
    END IF;

    IF vr_flgativo = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Estorno nao permitido, emprestimo em acordo';
      pr_des_reto := 'NOK';
      RAISE vr_erro;
    END IF;

    -- Buscar todos os lan�amentos efetuados
    FOR r_craplem in c_craplem(prc_cdcooper => pr_cdcooper
                              ,prc_nrdconta => pr_nrdconta
                              ,prc_nrctremp => pr_nrctremp
                              ,prc_dtmvtolt => pr_dtmvtolt) LOOP
      -- Estorno na data corrente
      IF r_craplem.dtmvtolt = rw_crapdat.dtmvtolt THEN
        IF r_craplem.cdhistor = 2388 THEN -- Valor Principal
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;

        ELSIF r_craplem.cdhistor = 2473 THEN --Juros +60
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2389 THEN --Juros atualiza��o
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;

        ELSIF r_craplem.cdhistor = 2390 THEN --Multa atraso
          -- Atualizar o valor pago de multa
          rw_crapepr.vlpgmupr := rw_crapepr.vlpgmupr - r_craplem.vllanmto;

        ELSIF r_craplem.cdhistor = 2475 THEN --Juros Mora
          -- Atualizar o valor pago de juros mora
          rw_crapepr.vlpgjmpr := rw_crapepr.vlpgjmpr - r_craplem.vllanmto;

        END IF;

        /* 1) Excluir Lancamento LEM */
        BEGIN
          DELETE FROM craplem t
           WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.nrctremp = pr_nrctremp
             AND t.cdhistor = r_craplem.cdhistor--decode(pr_idtipo, 'PP',2388,'TR',2388,'CC',2388,2391) --Recuperacao de prejuizo
             AND t.dtmvtolt = pr_dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Falha na exclusao CRAPLEM, cooper: ' || pr_cdcooper ||
                           ', conta: ' || pr_nrdconta;
            RAISE vr_erro;
        END;

        /* excluir lancamento LCM */
        BEGIN
          DELETE FROM craplcm t
           WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.cdhistor = 2386
             AND t.cdbccxlt = 100
             AND TO_NUMBER(trim(replace(t.cdpesqbb,'.',''))) = pr_nrctremp
             AND t.dtmvtolt = r_craplem.dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Falha na exclusao CRAPLCM, cooper: ' || pr_cdcooper ||
                           ', conta: ' || pr_nrdconta;
            RAISE vr_erro ;
        END;
        --

      ELSE
        -- Estorno de data anterior
        IF dt_gerarlcm IS NULL OR
           dt_gerarlcm <> r_craplem.dtmvtolt THEN
           --
           dt_gerarlcm := r_craplem.dtmvtolt;

          -- cria lancamento LCM
          IF gl_nrdolote IS NULL THEN
            OPEN c_busca_prx_lote(pr_dtmvtolt => RW_CRAPDAT.DTMVTOLT
                                 ,pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => r_craplem.cdagenci);
            fetch c_busca_prx_lote into vr_nrdolote;
            close c_busca_prx_lote;

            vr_nrdolote := nvl(vr_nrdolote,0) + 1;
            gl_nrdolote := vr_nrdolote;
          ELSE
            vr_nrdolote := gl_nrdolote;
          END IF;
          --

          FOR r_craplcm IN c_craplcm (r_craplem.cdcooper,
                                      r_craplem.nrdconta,
                                      r_craplem.dtmvtolt,
                                      r_craplem.nrctremp) LOOP

            empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdagenci => r_craplem.cdagenci
                                          ,pr_cdbccxlt => 100
                                          ,pr_cdoperad => '1'
                                          ,pr_cdpactra => r_craplem.cdagenci
                                          ,pr_nrdolote => vr_nrdolote
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_cdhistor => 2387 -- EST.RECUP.PREJUIZO
                                          ,pr_vllanmto => r_craplcm.vllanmto
                                          ,pr_nrparepr => 0
                                          ,pr_nrctremp => pr_nrctremp
                                          ,pr_nrseqava => 0
                                          ,pr_idlautom => 0
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_tab_erro => vr_tab_erro );

            IF vr_des_reto <> 'OK' THEN
              IF vr_tab_erro.count() > 0 THEN
                -- Atribui cr�ticas �s variaveis
                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                vr_dscritic := 'Falha estorno Pagamento '||vr_tab_erro(vr_tab_erro.first).dscritic;
                RAISE vr_erro;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Falha ao Estornar Pagamento '||sqlerrm;
                raise vr_erro;
              END IF;
            END IF;

          END LOOP;
        END IF;

        --
        IF r_craplem.cdhistor = 2388 THEN -- Valor Principal
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;

          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => r_craplem.cdagenci
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => '1'
                                           ,pr_cdpactra => r_craplem.cdagenci
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 600029
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdhistor => 2392 -- EST.PAG.PREJ.PRINCIP.
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vllanmto => r_craplem.vllanmto
                                           ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                           ,pr_txjurepr => 0
                                           ,pr_vlpreemp => 0
                                           ,pr_nrsequni => 0
                                           ,pr_nrparepr => r_craplem.nrdocmto
                                           ,pr_flgincre => true
                                           ,pr_flgcredi => false
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 -- batch
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

          IF vr_dscritic is not null THEN
            vr_dscritic := 'Ocorreu falha ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            raise vr_erro;
          END IF;
        ELSIF r_craplem.cdhistor = 2473 THEN --Juros +60
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;

          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => r_craplem.cdagenci
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => '1'
                                           ,pr_cdpactra => r_craplem.cdagenci
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 600029
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdhistor => 2474 -- EST PGT JUROS +60
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vllanmto => r_craplem.vllanmto
                                           ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                           ,pr_txjurepr => 0
                                           ,pr_vlpreemp => 0
                                           ,pr_nrsequni => 0
                                           ,pr_nrparepr => r_craplem.nrdocmto
                                           ,pr_flgincre => true
                                           ,pr_flgcredi => false
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 -- batch
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

          IF vr_dscritic is not null THEN
            vr_dscritic := 'Ocorreu falha ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            raise vr_erro;
          END IF;
        ELSIF r_craplem.cdhistor = 2389 THEN --Juros atualiza��o
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;

          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => r_craplem.cdagenci
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => '1'
                                           ,pr_cdpactra => r_craplem.cdagenci
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 600029
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdhistor => 2393 -- EST.PAGTO.JUROS PREJ
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vllanmto => r_craplem.vllanmto
                                           ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                           ,pr_txjurepr => 0
                                           ,pr_vlpreemp => 0
                                           ,pr_nrsequni => 0
                                           ,pr_nrparepr => r_craplem.nrdocmto
                                           ,pr_flgincre => true
                                           ,pr_flgcredi => false
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 -- batch
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

          IF vr_dscritic is not null THEN
            vr_dscritic := 'Ocorreu falha ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            raise vr_erro;
          END IF;
        ELSIF r_craplem.cdhistor = 2390 THEN --Multa atraso
          -- Atualizar o valor pago de multa
          rw_crapepr.vlpgmupr := rw_crapepr.vlpgmupr - r_craplem.vllanmto;

          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => r_craplem.cdagenci
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => '1'
                                           ,pr_cdpactra => r_craplem.cdagenci
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 600029
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdhistor => 2394 -- EST.PGT MULTA ATRASO
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vllanmto => r_craplem.vllanmto
                                           ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                           ,pr_txjurepr => 0
                                           ,pr_vlpreemp => 0
                                           ,pr_nrsequni => 0
                                           ,pr_nrparepr => r_craplem.nrdocmto
                                           ,pr_flgincre => true
                                           ,pr_flgcredi => false
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 -- batch
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

          IF vr_dscritic is not null THEN
            vr_dscritic := 'Ocorreu falha ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            raise vr_erro;
          END IF;
        ELSIF r_craplem.cdhistor = 2475 THEN --Juros Mora
          -- Atualizar o valor pago de juros mora
          rw_crapepr.vlpgjmpr := rw_crapepr.vlpgjmpr - r_craplem.vllanmto;
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => r_craplem.cdagenci
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => '1'
                                           ,pr_cdpactra => r_craplem.cdagenci
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 600029
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdhistor => 2476 -- EST.PGT JUROS MORA
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vllanmto => r_craplem.vllanmto
                                           ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                           ,pr_txjurepr => 0
                                           ,pr_vlpreemp => 0
                                           ,pr_nrsequni => 0
                                           ,pr_nrparepr => r_craplem.nrdocmto
                                           ,pr_flgincre => true
                                           ,pr_flgcredi => false
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 -- batch
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

          IF vr_dscritic is not null THEN
            vr_dscritic := 'Ocorreu falha ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            raise vr_erro;
          END IF;
        ELSIF r_craplem.cdhistor = 2391 THEN -- Abono
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => r_craplem.cdagenci
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => '1'
                                           ,pr_cdpactra => r_craplem.cdagenci
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 600029
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdhistor => 2395 -- ESTORNO ABONO PREJ.
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vllanmto => r_craplem.vllanmto
                                           ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                           ,pr_txjurepr => 0
                                           ,pr_vlpreemp => 0
                                           ,pr_nrsequni => 0
                                           ,pr_nrparepr => r_craplem.nrdocmto
                                           ,pr_flgincre => true
                                           ,pr_flgcredi => false
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 -- batch
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);

          IF vr_dscritic is not null THEN
            vr_dscritic := 'Ocorreu falha ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            raise vr_erro;
          END IF;
          --
          BEGIN
            UPDATE craplem lem
               SET lem.dtestorn = TRUNC(rw_crapdat.dtmvtolt)
             WHERE lem.rowid = r_craplem.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Ocorreu falha ao registrar data de estorno (2391): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              raise vr_erro;
          END;
        ELSIF r_craplem.cdhistor = 2701 THEN -- Pagamento
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => r_craplem.cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => '1'
                                         ,pr_cdpactra => r_craplem.cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => 2702 -- ESTORNO ABONO PREJ.
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => r_craplem.vllanmto
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => r_craplem.nrdocmto
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

          IF vr_dscritic is not null THEN
            vr_dscritic := 'Ocorreu falha ao retornar grava��o LEM (valor principal): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            raise vr_erro;
          END IF;

          BEGIN
            UPDATE craplem lem
               SET lem.dtestorn = TRUNC(rw_crapdat.dtmvtolt)
             WHERE lem.rowid = r_craplem.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Ocorreu falha ao registrar data de estorno (2701): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              raise vr_erro;
          END;

        END IF;
      END IF;
    END LOOP;

    -- Verifica se existem bems em Gravames
    OPEN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crapbpr
     INTO vr_existbpr;
    CLOSE cr_crapbpr;

    IF NVL(vr_existbpr,0) > 0 THEN
      -- Solicita a baixa no gravames
      GRVM0001.pc_desfazer_baixa_automatica(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctrpro => pr_nrctremp
                                           ,pr_des_reto => vr_des_reto
                                           ,pr_tab_erro => vr_tab_erro);
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Buscar o erro encontrado para gravar na vr_des_erro
          vr_dscritic := 'GRVM001 - ' || vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          pr_des_reto := 'NOK';
          RAISE vr_erro;
        END IF;
      END IF;

    END IF; -- END IF NVL(vr_existbpr,0) > 0 THEN

    --
    /* Atualiza CRAPEPR com o valor do lan�amento */
    BEGIN
      UPDATE crapepr c
         SET c.vlsdprej = nvl(rw_crapepr.vlsdprej,c.vlsdprej)  --vlsdprej - vr_vldescto - nvl(pr_vldabono,0)
            ,c.vlpgjmpr = nvl(rw_crapepr.vlpgjmpr,c.vlpgjmpr) --abs(nvl(c.vlpgjmpr,0) - nvl(vr_vlttjmpr,0))
            ,c.vlpgmupr = nvl(rw_crapepr.vlpgmupr,c.vlpgmupr) --abs(nvl(c.vlpgmupr,0) - nvl(vr_vlttmupr,0))
       WHERE c.nrdconta = pr_nrdconta
         AND c.nrctremp = pr_nrctremp
         AND c.cdcooper = pr_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Falha ao atualizar emprestimo para estorno: ' || sqlerrm;
        pr_des_reto := 'NOK';
        RAISE vr_erro;
    END;
    -- Confirma altera��es
    COMMIT;
  EXCEPTION
    WHEN vr_erro THEN
      -- Desfazer altera��es
      ROLLBACK;
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Falha na rotina pc_estorno_pagamento: ';
      END IF;
      --
      pr_des_reto := 'NOK';
      --
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => 0
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
     when others then
        ROLLBACK;
         if vr_dscritic is null then
            vr_dscritic := 'Falha geral rotina pc_estorno_pagamento: ' || sqlerrm;
         end if;

         -- Retorno n�o OK
         GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => 'PROCESSO'
                             ,pr_dscritic => vr_dscritic
                             ,pr_dsorigem => 'INTRANET'
                             ,pr_dstransa => 'PREJ0002_prj-Estorno pagamento.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => 'crps780'
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);
        -- Commit do LOG
        COMMIT;
  END pc_estorno_pagamento;

  PROCEDURE pc_estorno_pagamento_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                      ,pr_nrctremp IN VARCHAR2  -- contrato
                                      ,pr_dtmvtolt IN varchar2
                                      ,pr_idtipo   IN varchar2
                                      ,pr_xmllog   IN VARCHAR2            --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................

      Programa: pc_estorno_prejuizo_web
      Sistema : AyllosWeb
      Sigla   : PREJ
      Autor   : Jean Cal�o - Mout�S
      Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua o estorno de transferencias de contratos PP e TR para preju�zo
      Observacao: Rotina chamada pela tela Atenda / Presta��es, bot�o "Desfazer Preju�zo"
                  Tamb�m � chamada pela tela ESTPRJ (Estorno de preju�zos).

      Alteracoes:

     ..............................................................................*/
     -- Vari�veis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);

     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(500);
     vr_cddepart    number(3);
     vr_inprejuz    integer;

     -- Excess�es
     vr_exc_erro         EXCEPTION;

     cursor cr_crapope is
        select t.cddepart
        from   crapope t
        where  t.cdoperad = vr_cdoperad;

     cursor c_busca_abono is
        select 1
        from   craplem lem
        where  lem.cdcooper = vr_cdcooper
        and    lem.nrdconta = pr_nrdconta
        and    lem.nrctremp = pr_nrctremp
        and    lem.dtmvtolt > rw_crapdat.dtultdma
        and    lem.dtmvtolt <= rw_crapdat.dtultdia
        and    lem.cdhistor = 2391
        and not exists (select 1 from craplem t
                           where t.dtmvtolt > lem.dtmvtolt
                             and t.cdcooper = lem.cdcooper
                             and t.nrdconta = lem.nrdconta
                             and t.nrctremp = lem.nrctremp
                             and t.nrparepr = lem.nrdocmto
                             and t.cdhistor = 2395); -- abono


        vr_existe_abono integer := 0;

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
    open cr_crapope;
    fetch cr_crapope into vr_cddepart;
    close cr_crapope;

    /* Busca data de movimento */
    open btch0001.cr_crapdat(vr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    close btch0001.cr_crapdat;

    /*Busca informa��es do emprestimo */
    open cr_crapepr(pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta
                     , pr_nrctremp => pr_nrctremp);

    fetch cr_crapepr into rw_crapepr;
    if cr_crapepr%found then
       vr_inprejuz := rw_crapepr.inprejuz;
    end if;
    close cr_crapepr;

    if to_char(to_date(pr_dtmvtolt,'dd/mm/yyyy'),'yyyymm') < to_char(rw_crapdat.dtmvtolt,'yyyymm') then
       pr_des_erro := 'Impossivel fazer estorno do contrato, pois este pagamento/abono foi feito antes do mes vigente';
       raise vr_exc_erro;
    end if;

    /* Verifica se possui abono ativo, n�o pode efetuar o estorno do pagamento */
    open c_busca_abono;
    fetch c_busca_abono into vr_existe_abono;
    close c_busca_abono;

    if nvl(vr_existe_abono,0) = 1 then
       if pr_idtipo not in ('PA','TA','CA') then
         pr_des_erro := 'N�o � permitido efetuar o estorno do pagamento pois existe um lan�amento de abono.';
         raise vr_exc_erro;
       end if;
    end if;

    /* Gerando Log de Consulta */
    vr_dstransa := 'PREJ0002_prj-Efetuando estorno da transferencia para prejuizo, Cooper: ' || vr_cdcooper ||
                    ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                     || rw_crapepr.tpemprst || ', Data: ' || pr_dtmvtolt || ', indicador: ' || pr_idtipo ;


    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => 'INTRANET'
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    -- Commit do LOG
    COMMIT;

    if nvl(vr_inprejuz,2) = 1 then
      pc_estorno_pagamento(pr_cdcooper => vr_cdcooper
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_dtmvtolt => to_date(pr_dtmvtolt,'dd/mm/yyyy')
                           ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                           ,pr_tab_erro => vr_tab_erro);
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          pr_des_erro := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_cdcritic := 0;
          pr_des_erro := 'N�o foi possivel executar estorno do Pagamento do Preju�zo.';
        END IF;
        RAISE vr_exc_erro;
      END IF;
    ELSE
       pr_des_erro := 'Contrato n�o est� em preju�zo !';
       raise vr_exc_erro;
    END IF;

    vr_dstransa := 'PREJ0002_prj-Estorno da transfer�ncia para prejuizo, referente contrato: ' || pr_nrctremp ||', realizada com sucesso.';
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
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    -- Commit do LOG
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer altera��es
      ROLLBACK;
      if pr_des_erro is null then
         pr_des_erro := 'Erro na rotina pc_estorno_prejuizo: ';
      end if;
      pr_dscritic := pr_des_erro;
      -- Retorno n�o OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => 'PREJ0002_prj-Estorno transferencia para prejuizo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Desfazer altera��es
      ROLLBACK;
      pr_des_erro := 'Erro geral na rotina pc_estorno_prejuizo: '|| SQLERRM;
      pr_dscritic := pr_des_erro;
      pr_cdcritic := 0;
      pr_nmdcampo := '';
      -- Retorno n�o OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'PREJ0002_prj-Estorno da Transfer�ncia Preju�zo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_estorno_pagamento_web;

  PROCEDURE pc_pagamento_prejuizo_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                      ,pr_nrctremp   IN VARCHAR2  -- contrato
                                      ,pr_vlpagmto   in varchar2 -- valor do pagamento
                                      ,pr_vldabono   in varchar2 -- valor do abono
                                      ,pr_xmllog     IN VARCHAR2            --> XML com informa��es de LOG
                                      ,pr_cdcritic   OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic   OUT VARCHAR2             --> Descri��o da cr�tica
                                      ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo   OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro   OUT VARCHAR2) IS         --> Erros do processo

   /* .............................................................................

    Programa: pc_pagamento_prejuizo_web
    Sistema : AyllosWeb
    Sigla   : PREJ
    Autor   : Jean Cal�o - Mout�S
    Data    : Agosto/2017.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua o pagamento de prejuizos de contratos PP e TR (for�a o pagamento envio)
    Observacao: Rotina chamada pela tela PAGPRJ op�ao "For�ar pagamento prejuizo emprestimo"

    Alteracoes: 24/04/2018 - Nova Regra para bloqueio de pagamento realizado pela tela chamadora
                (Rafael Monteiro - Mouts)

              01/08/2018 - Ajuste para bloquear pagamento quando a conta est� em preju�zo
                           PJ 450 - Diego Simas - AMcom

    ..............................................................................*/
    -- Vari�veis
    vr_cdcooper    NUMBER;
    vr_nmdatela    VARCHAR2(25);
    vr_nmeacao     VARCHAR2(25);
    vr_cdagenci    VARCHAR2(25);
    vr_nrdcaixa    VARCHAR2(25);
    vr_idorigem    VARCHAR2(25);
    vr_cdoperad    VARCHAR2(25);
    vr_index_saldo PLS_INTEGER;
    vr_crapope     BOOLEAN;
    vr_vlapagar    NUMBER;
    vr_difpagto    NUMBER;
    vr_nrdrowid    ROWID;
    vr_dsorigem    VARCHAR2(100);
    vr_dstransa    VARCHAR2(500);
    vr_inprejuz    INTEGER;
    vr_vlsdprej    NUMBER;
    vr_vlsomato    NUMBER;
    vr_tab_saldos  EXTR0001.typ_tab_saldos;
    vr_dsctajud    crapprm.dsvlrprm%TYPE;         --> Parametro de contas que nao podem debitar os emprestimos
    vr_dsctactrjud crapprm.dsvlrprm%TYPE := null; --> Parametro de contas e contratos espec�ficos que nao podem debitar os emprestimos SD#618307
    vr_flgativo    INTEGER;
    -- Excess�es
    vr_exc_erro         EXCEPTION;

    -- Buscar dados do Operador
    CURSOR cr_crapope (pr_cdcooper IN crapace.cdcooper%TYPE
                      ,pr_cdoperad IN crapace.cdoperad%TYPE) IS
      SELECT t.cddepart,
             t.vlpagchq
        FROM crapope t
       WHERE t.cdcooper = pr_cdcooper
         AND UPPER(t.cdoperad) = UPPER(pr_cdoperad);

    rw_crapope cr_crapope%ROWTYPE;

    -- Buscar dados do acesso
    CURSOR cr_crapace(pr_cdcooper IN crapace.cdcooper%TYPE
                     ,pr_cdoperad IN crapace.cdoperad%TYPE
                     ,pr_nmdatela IN crapace.nmdatela%TYPE
                     ,pr_nmrotina IN crapace.nmrotina%TYPE
                     ,pr_cddopcao IN crapace.cddopcao%TYPE) IS
      SELECT ce.nmdatela
        FROM crapace ce
       WHERE ce.cdcooper        = pr_cdcooper
         AND UPPER(ce.cdoperad) = UPPER(pr_cdoperad)
         AND UPPER(ce.nmdatela) = UPPER(pr_nmdatela)
         AND UPPER(ce.nmrotina) = UPPER(pr_nmrotina)
         AND UPPER(ce.cddopcao) = UPPER(pr_cddopcao)
         AND ce.idambace        = 2;

    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.vllimcre
          ,ass.inprejuz
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
             AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

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

    -- Validar permissao do operador para inserir valor de abono
    IF NVL(pr_vldabono,0) > 0 THEN
      -- Verifica as permiss�es de execu��o no cadastro
      OPEN cr_crapace(vr_cdcooper, --pr_cdcooper,
                      vr_cdoperad, --pr_cdoperad,
                      'ATENDA',--pr_nmdatela,
                      'PRESTACOES', --pr_nmrotina,
                      'A' --pr_cddopcao -- OPCAO ABONO
                      );
      FETCH cr_crapace INTO vr_nmdatela;
      -- Verifica se foi encontrada permiss�o para Pagamento de Abono
      IF cr_crapace%NOTFOUND THEN
        CLOSE cr_crapace;
        -- 036 - Operacao nao autorizada.
        pr_cdcritic := 36;
        --pr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)||' Operador n�o possui privil�gio para inserir abono';
        pr_des_erro := 'Pagamento de abono n�o autorizado, operador n�o possui permiss�o para conceder abono.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapace;
      END IF;
    END IF;

    -- Buscar dados do operador
    OPEN cr_crapope(vr_cdcooper,vr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;

    vr_crapope := cr_crapope%FOUND;
    CLOSE cr_crapope;

    /* Busca data de movimento */
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Selecionar Associado
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;

    -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
    vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => vr_cdcooper,
                                             pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');
     -- Lista de contas e contratos espec�ficos que nao podem debitar os emprestimos (formato="(cta,ctr)") SD#618307
    vr_dsctactrjud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => vr_cdcooper
                                               ,pr_cdacesso => 'CTA_CTR_ACAO_JUDICIAL');

    -- Condicao para verificar se permite incluir as linhas parametrizadas
    IF INSTR(',' || vr_dsctajud || ',',',' || pr_nrdconta || ',') > 0 THEN
      pr_des_erro := 'Aten��o! Pagamento n�o permitido. Verifique situa��o da conta.';
      RAISE vr_exc_erro;
    END IF;

    -- Condicao para verificar se permite incluir as linhas parametrizadas SD#618307
    IF INSTR(replace(vr_dsctactrjud,' '),'('||trim(to_char(pr_nrdconta))||','||trim(to_char(pr_nrctremp))||')') > 0 THEN
      pr_des_erro := 'Aten��o! Pagamento n�o permitido. Verifique situa��o da conta.';
      RAISE vr_exc_erro;
    END IF;
    --

    -- Acordo com modulo.
    RECP0001.pc_verifica_acordo_ativo (pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp
                                      ,pr_cdorigem => 3
                                      ,pr_flgativo => vr_flgativo
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF vr_flgativo = 1 THEN
      vr_cdcritic := 0;
      pr_des_erro := 'Pagamento nao permitido, emprestimo em acordo';
      RAISE vr_exc_erro;
    END IF;
    --
    --Limpar tabela saldos
    vr_tab_saldos.DELETE;
    --Obter Saldo do Dia
    EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => vr_cdcooper
                               ,pr_rw_crapdat => rw_crapdat
                               ,pr_cdagenci   => nvl(vr_cdagenci,1)
                               ,pr_nrdcaixa   => nvl(vr_nrdcaixa,1)
                               ,pr_cdoperad   => nvl(vr_cdoperad,1)
                               ,pr_nrdconta   => pr_nrdconta
                               ,pr_vllimcre   => rw_crapass.vllimcre
                               ,pr_dtrefere   => rw_crapdat.dtmvtolt
                               ,pr_flgcrass   => FALSE
                               ,pr_des_reto   => pr_des_erro
                               ,pr_tab_sald   => vr_tab_saldos
                               ,pr_tipo_busca => 'A'
                               ,pr_tab_erro   => vr_tab_erro);

    --Buscar Indice
    vr_index_saldo := vr_tab_saldos.FIRST;
    IF vr_index_saldo IS NOT NULL THEN
      --Acumular Saldo
      vr_vlsomato := ROUND( nvl(vr_tab_saldos(vr_index_saldo).vlsddisp, 0) +
                            nvl(vr_tab_saldos(vr_index_saldo).vlsdchsl, 0) +
                            nvl(vr_tab_saldos(vr_index_saldo).vllimcre, 0),2); --Valor liberado no dia
    END IF;

    BEGIN
      vr_vlapagar := nvl(to_number(pr_vlpagmto),0) /*+ nvl(to_number(pr_vldabono),0)*/;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Falha ao somar pagamento e/ou abono : ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    --Valor a Pagar Maior Soma total
    IF nvl(vr_vlapagar, 0) > nvl(vr_vlsomato, 0) THEN

      --Se encontrou operador
      IF vr_crapope THEN
        --Diferenca no valor pago
        vr_difpagto := nvl(vr_vlapagar, 0) - nvl(vr_vlsomato, 0);
        --Valor Diferenca Maior Limite Pagamento Cheque
        IF vr_difpagto > nvl(rw_crapope.vlpagchq, 0) THEN
          pr_des_erro := 'Saldo alcada do operador insuficiente.';
          RAISE vr_exc_erro;
        END IF;
      END IF;

    END IF;

    /*Busca informa��es do emprestimo */
    OPEN cr_crapepr(pr_cdcooper => vr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_nrctremp => pr_nrctremp);

    FETCH cr_crapepr INTO rw_crapepr;
    IF cr_crapepr%FOUND THEN
       vr_inprejuz := rw_crapepr.inprejuz;
       vr_vlsdprej := nvl(rw_crapepr.vlsdprej,0) + nvl(rw_crapepr.vlttmupr,0) + nvl(rw_crapepr.vlttjmpr,0);
    END IF;
    CLOSE cr_crapepr;
  -- In�cio - PJ 450 (Diego Simas - AMcom)
  IF rw_crapass.inprejuz = 1 THEN
     pr_des_erro := 'Conta em preju�zo, pagamento deve ser efetuado atrav�s da op��o Bloqueado Preju�zo.';
     RAISE vr_exc_erro;
  END IF;
  -- Fim - PJ 450 (Diego Simas - AMcom)

    IF nvl(vr_inprejuz,2) = 1 THEN

       IF vr_vlsdprej > 0 THEN
           pc_crps780_1(pr_cdcooper => vr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_nrctremp => pr_nrctremp,
                        pr_vlpagmto => pr_vlpagmto,
                        pr_vldabono => pr_vldabono,
                        pr_cdagenci => 1,
                        pr_cdoperad => vr_cdoperad,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             pr_des_erro := 'Erro no pagamento: ' || vr_dscritic;
             RAISE vr_exc_erro;
           END IF;
       ELSE
          pr_des_erro := 'N�o existe saldo de preju�zo � pagar!';
          RAISE vr_exc_erro;
       END IF;

    ELSE
       pr_des_erro := 'Contrato informado n�o possui saldo devedor.';
       RAISE vr_exc_erro;
    END IF;

    IF vr_des_reto <> 'OK' THEN
       pr_des_erro := 'Erro no pagamento do prejuizo: ' || SQLERRM;
       RAISE vr_exc_erro;
    END IF;

    vr_dstransa := 'Pagamento de prejuizo realizado com sucesso, Cooper: ' || vr_cdcooper ||
                    ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                     || rw_crapepr.tpemprst || ' Data: ' || to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY') ||
                     ', Vlr Pagto: ' || pr_vlpagmto || ', Vlr abono: ' || pr_vldabono || 'Operador: '||vr_cdoperad;
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
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    -- Commit do LOG
    COMMIT;
  EXCEPTION
   WHEN vr_exc_erro THEN
     -- Desfazer altera��es
     ROLLBACK;
     if pr_des_erro is null then
        pr_des_erro := 'Erro na rotina pc_transfere_prejuizo: ';
     end if;
     pr_dscritic := pr_des_erro;
     -- Retorno n�o OK
     GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                         ,pr_cdoperad => vr_cdoperad
                         ,pr_dscritic => NVL(pr_dscritic,' ')
                         ,pr_dsorigem => 'INTRANET'
                         ,pr_dstransa => 'PREJ0002_prj-Pagamento for�ado de prejuizo.'
                         ,pr_dttransa => TRUNC(SYSDATE)
                         ,pr_flgtrans => 0 --> ERRO/FALSE
                         ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                         ,pr_idseqttl => 1
                         ,pr_nmdatela => vr_nmdatela
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdrowid => vr_nrdrowid);
    -- Commit do LOG
    COMMIT;
     -- Carregar XML padrao para variavel de retorno nao utilizada.
     -- Existe para satisfazer exigencia da interface.
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                   '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   WHEN OTHERS THEN
     -- Desfazer altera��es
     ROLLBACK;
     pr_des_erro := 'Erro geral na rotina pc_transfere_prejuizo: '|| SQLERRM;
     pr_dscritic := pr_des_erro;
     pr_cdcritic := 0;
     pr_nmdcampo := '';
     -- Retorno n�o OK
     GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                         ,pr_cdoperad => vr_cdoperad
                         ,pr_dscritic => NVL(pr_dscritic,' ')
                         ,pr_dsorigem => vr_dsorigem
                         ,pr_dstransa => 'PREJ0002_prj-Transfer�ncia Preju�zo.'
                         ,pr_dttransa => TRUNC(SYSDATE)
                         ,pr_flgtrans => 0 --> ERRO/FALSE
                         ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                         ,pr_idseqttl => 1
                         ,pr_nmdatela => vr_nmdatela
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdrowid => vr_nrdrowid);
     -- Commit do LOG
     COMMIT;
     -- Carregar XML padrao para variavel de retorno nao utilizada.
     -- Existe para satisfazer exigencia da interface.
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                   '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_pagamento_prejuizo_web;

  PROCEDURE pc_consulta_pagamento_web(pr_dtpagto  in varchar2
                                     ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                     ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
             						 		 			   ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
 			    	          	 		 			   ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
					    				         			 ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
         			    									 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
				              							 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
									              		 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_consulta_pagamento_web
     Sistema : Rotinas referentes a pagamento de transferencia para prejuizo
     Sigla   : PREJ
     Autor   : Jean Cal�o (Mout�S)
     Data    : Ago/2017.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para consultar os estornos

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE

      -- Cursor dos abonos
      CURSOR cr_abono (pr_cdcooper crapepr.cdcooper%TYPE
                      ,pr_dtpagto  craplem.dtmvtolt%type
                      ,pr_nrdconta crapepr.nrdconta%TYPE
                      ,pr_nrctremp crapepr.nrctremp%TYPE) IS
        SELECT lem.dtmvtolt
              ,lem.nrctremp
              ,lem.vllanmto
          FROM craplem lem,
               crapepr epr
         WHERE lem.cdcooper = pr_cdcooper
           AND lem.nrdconta = decode(pr_nrdconta, 0, lem.nrdconta, pr_nrdconta)
           AND lem.nrctremp = decode(pr_nrctremp, 0, lem.nrctremp, pr_nrctremp)
           AND lem.dtmvtolt = nvl(pr_dtpagto, lem.dtmvtolt)
           AND lem.cdhistor = 2391 -- abono
           AND lem.dtmvtolt >= SYSDATE - 360
           AND lem.dtmvtolt <= to_date('20/06/2018','dd/mm/yyyy')
           AND NOT EXISTS (SELECT 1
                             FROM craplem lem2
                            WHERE lem2.cdcooper = lem.cdcooper
                              AND lem2.nrdconta = lem.nrdconta
                              AND lem2.nrctremp = lem.nrctremp
                              AND lem2.cdhistor = 2395 -- Estorno abono
                              AND lem2.dtmvtolt >= SYSDATE - 360
                              AND lem2.vllanmto = lem.vllanmto)
           AND epr.cdcooper  = lem.cdcooper
           AND epr.nrdconta  = lem.nrdconta
           AND epr.nrctremp  = decode(pr_nrctremp, 0,epr.nrctremp,pr_nrctremp)
           --
           UNION -- union com distinct
           --
           SELECT lem.dtmvtolt
                 ,lem.nrctremp
                 ,lem.vllanmto
             FROM craplem lem
            WHERE lem.cdcooper = pr_cdcooper
              AND lem.nrdconta = decode(pr_nrdconta, 0, lem.nrdconta, pr_nrdconta)
              AND lem.nrctremp = decode(pr_nrctremp, 0, lem.nrctremp, pr_nrctremp)
              AND lem.dtmvtolt = nvl(pr_dtpagto, lem.dtmvtolt)
              AND lem.cdhistor = 2391 -- abono
              AND lem.dtestorn IS NULL
           ORDER BY vllanmto
           ;

      -- Pagamentos efetudos
      CURSOR cr_pagtos (pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_dtpagto  craplem.dtmvtolt%type
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%TYPE) IS
        SELECT lcm.dtmvtolt dtmvtolt
              ,lcm.vllanmto vllanmto
              ,to_number(trim(REPLACE(lcm.cdpesqbb,'.',''))) nrctremp
          FROM craplcm lcm,
               crapepr epr
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = decode(pr_nrdconta, 0, lcm.nrdconta, pr_nrdconta)
           AND to_number(trim(REPLACE(lcm.cdpesqbb,'.',''))) = decode(pr_nrctremp, 0, to_number(trim(REPLACE(lcm.cdpesqbb,'.',''))), pr_nrctremp)

           AND lcm.cdhistor = 2386-- Pagamento
           AND lcm.dtmvtolt = nvl(pr_dtpagto, lcm.dtmvtolt)
           AND lcm.dtmvtolt >= SYSDATE - 200
           AND lcm.dtmvtolt <= to_date('20/06/2018','dd/mm/yyyy')

           -- N�o estornados
           AND NOT EXISTS (SELECT 1
                             FROM craplcm lcm2
                            WHERE lcm2.cdcooper = lcm.cdcooper
                              AND lcm2.nrdconta = lcm.nrdconta
                              AND lcm2.cdhistor = 2387 -- estorno de pagamento
                              AND to_number(trim(replace(lcm2.cdpesqbb,'.',''))) = to_number(trim(REPLACE(lcm.cdpesqbb,'.','')))
                              AND lcm2.vllanmto = lcm.vllanmto
                              AND lcm2.dtmvtolt >= SYSDATE - 200)
           AND epr.cdcooper  = lcm.cdcooper
           AND epr.nrdconta  = lcm.nrdconta
           AND epr.nrctremp  = decode(pr_nrctremp, 0,epr.nrctremp,pr_nrctremp)
           --
           UNION
           --
           SELECT lem.dtmvtolt dtmvtolt
                 ,lem.vllanmto vllanmto
                 ,lem.nrctremp nrctremp
             FROM craplem lem
            WHERE lem.cdcooper = pr_cdcooper
              AND lem.nrdconta = decode(pr_nrdconta, 0, lem.nrdconta, pr_nrdconta)
              AND lem.nrctremp = decode(pr_nrctremp, 0, lem.nrctremp, pr_nrctremp)
              AND lem.dtmvtolt = nvl(pr_dtpagto, lem.dtmvtolt)
              AND lem.cdhistor = 2701 -- pagamento
              AND lem.dtestorn IS NULL
           ORDER BY vllanmto;
      --
      -- Vari�vel de cr�ticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_contador      PLS_INTEGER := 0;
      vr_idtipo        varchar2(2);
      vr_dstipo        varchar2(25);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper         PLS_INTEGER;
      vr_cdoperad         VARCHAR2(100);
      vr_nmdatela         VARCHAR2(100);
      vr_nmeacao          VARCHAR2(100);
      vr_cdagenci         VARCHAR2(100);
      vr_nrdcaixa         VARCHAR2(100);
      vr_idorigem         VARCHAR2(100);
      vr_dstransa         varchar2(200);
      vr_dsorigem         VARCHAR2(100);
      vr_nrdrowid         ROWID;
      vr_nao_existe       BOOLEAN;
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

      IF nvl(pr_nrdconta,0) = 0 THEN
        vr_dscritic := 'Favor preencher o campo da conta!';
        RAISE vr_exc_saida;
      END IF;

      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      --
      vr_nao_existe :=  TRUE;
      --
      -- Buscar Abonos
      FOR rw_abono IN cr_abono (pr_cdcooper => vr_cdcooper
                               ,pr_dtpagto =>  to_date(pr_dtpagto,'dd/mm/yyyy')
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => NVL(pr_nrctremp,0)) LOOP
        -- Buscar dados do contrato
        OPEN cr_crapepr(vr_cdcooper, pr_nrdconta, rw_abono.nrctremp);
        FETCH cr_crapepr INTO rw_crapepr;
        CLOSE cr_crapepr;

        IF rw_crapepr.tpemprst = 1 THEN
          vr_idtipo := 'PA';
          vr_dstipo := 'Abono-Empr�stimo PP';

        ELSIF rw_crapepr.tpemprst = 0 THEN
          vr_idtipo := 'TA';
          vr_dstipo := 'Abono-Empr�stimo TR';
        ELSIF rw_crapepr.nrdconta = nvl(rw_abono.nrctremp,0)
          AND rw_crapepr.cdlcremp = 100 THEN
                 vr_idtipo := 'CA';
                 vr_dstipo := 'Abono-Conta corrente';
        END IF;
        IF NVL(rw_abono.vllanmto,0) <> 0 THEN
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtpagto', pr_tag_cont => to_char(rw_abono.dtmvtolt,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => pr_nrdconta, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => rw_abono.nrctremp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlemprst', pr_tag_cont => rw_abono.vllanmto, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idtipo', pr_tag_cont => vr_idtipo, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstipo', pr_tag_cont => vr_dstipo, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;
        END IF;
        vr_nao_existe := FALSE;
      END LOOP; -- Fim loop Abono

      --
      -- Pagamentos
      FOR rw_pagtos IN cr_pagtos (pr_cdcooper => vr_cdcooper
                                 ,pr_dtpagto =>  to_date(pr_dtpagto,'dd/mm/yyyy')
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => NVL(pr_nrctremp,0)) LOOP
        OPEN cr_crapepr(vr_cdcooper, pr_nrdconta, rw_pagtos.nrctremp);
        FETCH cr_crapepr INTO rw_crapepr;
        CLOSE cr_crapepr;

        IF rw_crapepr.tpemprst = 1 THEN
          vr_idtipo := 'PP';
          vr_dstipo := 'Pgto-Empr�stimo PP';

        ELSIF rw_crapepr.tpemprst = 0 THEN
          vr_idtipo := 'TR';
          vr_dstipo := 'Pgto-Empr�stimo TR';
        ELSIF rw_crapepr.nrdconta = rw_crapepr.nrctremp
          AND rw_crapepr.cdlcremp = 100 THEN
            vr_idtipo := 'CC';
            vr_dstipo := 'Pgto-Conta corrente';
        END IF;
        IF NVL(rw_pagtos.vllanmto, 0) > 0 THEN
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtpagto', pr_tag_cont => to_char(rw_pagtos.dtmvtolt,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => pr_nrdconta, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => rw_crapepr.nrctremp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlemprst', pr_tag_cont => rw_pagtos.vllanmto, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idtipo', pr_tag_cont => vr_idtipo, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstipo', pr_tag_cont => vr_dstipo, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;
        END IF;
        vr_nao_existe := FALSE;
      END LOOP; -- Loop de pagamentos

      --
      -- Verificar se algum cursor executou
      IF vr_nao_existe THEN
        vr_dscritic := 'N�o � poss�vel estornar, n�o existem pagamentos para a conta/contrato informado.';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PREJ0002_prj.pc_consulta_pagamentos: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        -- gravar LOG de teste
        vr_dstransa := 'Consulta pagamentos: ' || pr_dtpagto || ', conta: ' || pr_nrdconta || ', contrato: ' || pr_nrctremp;

        -- Gerando Log de Consulta
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> SUCESSO/TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => PR_NRDCONTA
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Commit do LOG
        COMMIT;

    END;

  END pc_consulta_pagamento_web;

  PROCEDURE pc_valores_contrato_web(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_consulta_pagamento_web
     Sistema : Rotinas referentes a pagamento de transferencia para prejuizo
     Sigla   : PREJ
     Autor   : Jean Cal�o (Mout�S)
     Data    : Ago/2017.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para consultar os estornos

     Observacao: -----
     Alteracoes: 05/07/2018 - Inclus�o de campos de IOF do Preju�zo - P410 - Marcos - Envolti
     ..............................................................................*/
    DECLARE
      -- Cursor dos pagamentos
      CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%type) IS
       SELECT epr.tpemprst,
              epr.cdcooper,
              epr.nrdconta,
              epr.nrctremp,
              epr.cdlcremp,
              epr.vlsdprej,
              epr.vlpgmupr,
              epr.vlttmupr,
              epr.vlpgjmpr,
              epr.vlttjmpr,
              epr.vlpiofpr,
              epr.vltiofpr
         FROM crapepr epr
        WHERE epr.cdcooper = pr_cdcooper
          and epr.nrdconta = pr_nrdconta
          and epr.nrctremp = pr_nrctremp
          and epr.inprejuz = 1;

      -- Vari�vel de cr�ticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_contador      PLS_INTEGER := 0;

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
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Buscar contratos
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => vr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp) LOOP
        rw_crapepr.vlttmupr := rw_crapepr.vlttmupr - nvl(rw_crapepr.vlpgmupr,0);
        rw_crapepr.vlttjmpr := rw_crapepr.vlttjmpr - nvl(rw_crapepr.vlpgjmpr,0);
        rw_crapepr.vltiofpr := rw_crapepr.vltiofpr - nvl(rw_crapepr.vlpiofpr,0);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapepr.nrdconta, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => rw_crapepr.nrctremp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlsdprej', pr_tag_cont => replace(rw_crapepr.vlsdprej,'.',','), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlttmupr', pr_tag_cont => replace(rw_crapepr.vlttmupr,'.',','), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlttjmpr', pr_tag_cont => replace(rw_crapepr.vlttjmpr,'.',','), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vltiofpr', pr_tag_cont => replace(rw_crapepr.vltiofpr,'.',','), pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;

      END LOOP; /* END FOR rw_tbepr_estorno */

      IF vr_contador <= 0 THEN
        vr_dscritic := 'Nao existe pagamentos gerado para a conta informada.';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PREJ0002_prj.pc_valores_contrato: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_valores_contrato_web;

FUNCTION fn_dias_atraso_emp(pr_cdcooper IN crapepr.cdcooper%TYPE,
                            pr_nrdconta IN crapepr.nrdconta%TYPE,
                            pr_nrctremp IN crapepr.nrctremp%TYPE) RETURN NUMBER IS
  /* .............................................................................

   Programa: fn_dias_atraso_emp
   Sistema : Rotinas referentes aos dias de atraso de contratos
   Sigla   : Prej
   Autor   : Rafael Muniz Monteiro
   Data    : Julho/2018.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Buscar os dias de atraso de acordo com o tipo

   Observacao: -----
   Alteracoes:
   ..............................................................................*/
  CURSOR cr_crapepr (prc_cdcooper crapepr.cdcooper%TYPE,
                     prc_nrdconta crapepr.nrdconta%TYPE,
                     prc_nrctremp crapepr.nrctremp%TYPE)IS
    SELECT epr.qtmesdec,
           epr.tpemprst,
           epr.dtdpagto,
           epr.qtlcalat,
           epr.qtprecal,
           epr.cdagenci
      FROM crapepr epr
     WHERE epr.cdcooper = prc_cdcooper
       AND epr.nrdconta = prc_nrdconta
       AND epr.nrctremp = prc_nrctremp;
  rw_crapepr cr_crapepr%rowtype;

  CURSOR cr_crappep (prc_cdcooper crappep.cdcooper%TYPE,
                     prc_nrdconta crappep.nrdconta%TYPE,
                     prc_nrctremp crappep.nrctremp%TYPE,
                     prc_dtmvtoan crapdat.dtmvtoan%TYPE,
                     prc_cdagenci crapass.cdagenci%TYPE)IS
/*    SELECT pep.nrdconta
          ,pep.nrctremp
          ,MIN(pep.dtvencto) dtvencto
      FROM crappep pep
          ,crapass ass
     WHERE pep.cdcooper = prc_cdcooper
       AND (pep.inliquid = 0 OR pep.inprejuz = 1)
       AND pep.nrdconta  = prc_nrdconta
       AND pep.nrctremp  = prc_nrctremp
       AND pep.dtvencto <= prc_dtmvtoan
       AND ass.cdcooper = pep.cdcooper
       AND ass.nrdconta = pep.nrdconta
       AND ass.cdagenci = decode(prc_cdagenci,0,ass.cdagenci,prc_cdagenci)
     GROUP BY pep.nrdconta
             ,pep.nrctremp;  */
    SELECT MIN(pep.dtvencto) dtvencto
      FROM crappep pep
     WHERE pep.cdcooper = prc_cdcooper
       AND pep.nrdconta = prc_nrdconta
       AND pep.nrctremp = prc_nrctremp
       AND pep.inliquid = 0
       AND pep.dtvencto <= prc_dtmvtoan;

  CURSOR cr_cessao_carga (prc_cdcooper crappep.cdcooper%TYPE,
                          prc_nrdconta crappep.nrdconta%TYPE,
                          prc_nrctremp crappep.nrctremp%TYPE)IS
    SELECT ces.dtvencto
      FROM tbcrd_cessao_credito ces
      JOIN crapepr epr
        ON epr.cdcooper = ces.cdcooper
       AND epr.nrdconta = ces.nrdconta
       AND epr.nrctremp = ces.nrctremp
     WHERE ces.cdcooper = prc_cdcooper
       AND ces.nrdconta = prc_nrdconta
       AND ces.nrctremp = prc_nrctremp
       AND epr.inliquid = 0 ;

  FunctionResult      NUMBER := 0;
  vr_qtmesdec         NUMBER := 0; --> Meses corridos do empr�stimo
  vr_qtprecal_retor   NUMBER := 0; --> Quantidade % de parcelas calculadas
  vr_idxpep           VARCHAR2(50);
  vr_dtvencto         crappep.dtvencto%TYPE;

BEGIN

  OPEN btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat  INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_crapepr(pr_cdcooper,
                  pr_nrdconta,
                  pr_nrctremp);
  FETCH cr_crapepr INTO rw_crapepr;
  CLOSE cr_crapepr;

  -- TR
  IF rw_crapepr.tpemprst = 0 THEN

    vr_qtmesdec := rw_crapepr.qtmesdec;

    IF rw_crapepr.dtdpagto IS NOT NULL THEN
      -- Se o pagamento for no mes corrente e posterior ao dia atual
      -- OU
      -- Se o pagamento for posterior a data atual e estivermos no processamento semanal
      IF (trunc(rw_crapepr.dtdpagto,'mm') = trunc(rw_crapdat.dtmvtolt,'mm') AND to_char(rw_crapepr.dtdpagto,'dd') > to_char(rw_crapdat.dtmvtolt,'dd'))
      OR (trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapdat.dtmvtopr,'mm') AND rw_crapepr.dtdpagto > rw_crapdat.dtmvtolt) THEN
        -- Decrementar a quantidade de meses decorridos
        vr_qtmesdec := vr_qtmesdec - 1;
      END IF;
    END IF;
    -- Se o m�s corrente � o mesmo do pr�ximo dia util
    IF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapdat.dtmvtopr,'mm') THEN
      /* Saldo calculado pelo crps616.p e crps665.p */
      vr_qtprecal_retor := nvl(rw_crapepr.qtlcalat,0) + nvl(rw_crapepr.qtprecal,0);
    ELSE
      -- Utilizar informa��es da tabela mesmo
      vr_qtprecal_retor := rw_crapepr.qtprecal;
    END IF;
    --
    FunctionResult := ((vr_qtmesdec - vr_qtprecal_retor) * 30);

  ELSIF rw_crapepr.tpemprst = 1 THEN -- PP

    FOR rw_crappep IN cr_crappep(pr_cdcooper,
                                 pr_nrdconta,
                                 pr_nrctremp,
                                 rw_crapdat.dtmvtoan,
                                 rw_crapepr.cdagenci) LOOP

      vr_dtvencto := rw_crappep.dtvencto;
    END LOOP;
    FOR rw_cessao_carga IN cr_cessao_carga(pr_cdcooper,
                               pr_nrdconta,
                               pr_nrctremp) LOOP
       vr_dtvencto  := rw_cessao_carga.dtvencto;
    END LOOP;

    IF vr_dtvencto IS NOT NULL THEN
      -- Calcular a quantidade de dias em atraso
      FunctionResult := rw_crapdat.dtmvtolt - vr_dtvencto;
    ELSE
      -- Sem atraso e risco A
      FunctionResult := 0;
    END IF;

  END IF;

  RETURN(FunctionResult);

END fn_dias_atraso_emp;


END PREJ0002_prj;
/
