
DECLARE

  pr_cdcooper NUMBER := 1;
  pr_dtestorn DATE   := to_date('11/10/2021','dd/mm/yyyy');
  pr_dtinilan DATE   := TO_date('12/10/2021 04:00','dd/mm/yyyy hh24:MI');
  pr_dtfinlan DATE   := TO_date('12/10/2021 04:30','dd/mm/yyyy hh24:MI');
  vr_dsINC    VARCHAR2(200) := 'INC0108929';
  
  vr_input_file  utl_file.file_type;
  vr_setlinha    VARCHAR2(100);
  vr_dsdiret  VARCHAR2(200);
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(2000);
  vr_exc_erro EXCEPTION;
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  gl_nrdolote NUMBER;
  vr_des_reto VARCHAR2(2000);
  vr_tab_erro gene0001.typ_tab_erro ;
  vr_des_erro VARCHAR2(2000);  
  vr_totalest NUMBER;
  vr_nrlinha  NUMBER;
  vr_nracordo NUMBER;
  
  TYPE typ_bordero IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
  vr_tab_bordero_estornado typ_bordero;

  CURSOR cr_tbrecup_acordo (pr_nracordo IN NUMBER)IS
    SELECT a.nracordo,
           a.cdcooper,
           a.nrdconta,
           c.cdorigem,
           c.nrctremp,
           a.vlbloqueado
      FROM tbrecup_acordo a,
           tbrecup_acordo_contrato c
     WHERE a.cdcooper = pr_cdcooper
       AND a.nracordo = pr_nracordo
       AND a.nracordo = c.nracordo
       ORDER BY c.cdorigem;

  CURSOR cr_crapepr_aco(pr_cdcooper in number
                   ,pr_nrdconta in number
                   ,pr_nrctremp in number) IS
    SELECT *
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
  rw_crapepr_aco cr_crapepr_aco%ROWTYPE;
  
  CURSOR cr_crapass_aco (pr_cdcooper in number
                        ,pr_nrdconta in NUMBER)IS
    SELECT a.*
      FROM crapass a 
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta; 
  rw_crapass_aco cr_crapass_aco%ROWTYPE;
  
  CURSOR cr_crapbdt (pr_nracordo IN NUMBER) IS
    SELECT DISTINCT b.nrborder,b.inprejuz
      FROM tbrecup_acordo a, 
           tbrecup_acordo_contrato c,
           tbdsct_titulo_cyber t, 
           crapbdt b
    WHERE a.cdcooper = 1
    AND a.nracordo = c.nracordo
    AND c.cdorigem IN (4)
    AND c.nrctremp = t.nrctrdsc
    AND a.cdcooper = t.cdcooper
    AND a.nrdconta = t.nrdconta
    AND t.cdcooper = b.cdcooper
    AND t.nrdconta = b.nrdconta
    AND t.nrborder = b.nrborder
    AND a.nracordo = pr_nracordo;
  rw_crapbdt cr_crapbdt%ROWTYPE;

  PROCEDURE pc_gera_log (pr_nracordo  IN NUMBER,
                         pr_cdorigem  IN NUMBER,
                         pr_nrctremp  IN NUMBER,
                         pr_log       IN VARCHAR2 )IS
    vr_dslog VARCHAR2(1000);
  BEGIN
    
    vr_dslog := to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||' -->  '||
                'ACORDO '  || pr_nracordo || '; ';
    IF pr_cdorigem IS NOT NULL THEN            
      vr_dslog :=  vr_dslog ||'cdorigem '|| pr_cdorigem || '; ' ;
    END IF;
    IF pr_nrctremp IS NOT NULL THEN            
      vr_dslog :=  vr_dslog ||'nrctremp '|| pr_nrctremp || ': ' ;
    END IF;            
    
    vr_dslog :=  vr_dslog ||pr_log;
                                                    
                                                    
    BTCH0001.pc_gera_log_batch ( pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_dsINC||'.log' 
                                ,pr_dsdirlog     => vr_dsdiret||'/'||vr_dsINC
                                ,pr_des_log      => vr_dslog);
  END;

  /* Rotina para estornar pagamento de  prejuizo PP, TR e CC */
  PROCEDURE pc_estorno_pagamento_epr_prej(pr_cdcooper IN number
                                ,pr_cdagenci in number
                                ,pr_nrdconta in number
                                ,pr_nrctremp in number
                                ,pr_dtmvtolt in DATE
                                ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                ,pr_tab_erro OUT gene0001.typ_tab_erro) IS

    
      TYPE typ_reg_historico IS RECORD (cdhistor craphis.cdhistor%TYPE
                                      , dscritic VARCHAR2(100));

      TYPE typ_tab_historicos IS TABLE OF typ_reg_historico INDEX BY PLS_INTEGER;

      vr_tab_historicos typ_tab_historicos;

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
                lem.rowid,
                lem.nrdolote,
                lem.nrparepr
           from craplem lem
          where lem.cdcooper = prc_cdcooper
            and lem.nrdconta = prc_nrdconta
            and lem.nrctremp = prc_nrctremp
            and lem.dtmvtolt = prc_dtmvtolt -- ESTORNAR TUDO DO DIA
            AND lem.dthrtran >= pr_dtinilan
            AND lem.dthrtran <= pr_dtfinlan
            and lem.cdhistor in (2701  -- Valor pagamento
                                ,2388  -- Valor Principal
                                ,2473  -- Juros +60
                                ,2389  -- Juros atualização
                                ,2390  -- Multa  atraso
                                ,2475  -- Juros Mora
                                ,2391  -- Abono
                                );
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
                      prc_nrctremp craplem.nrctremp%TYPE,
                      prc_vllanmto craplem.vllanmto%TYPE) IS
      SELECT t.vllanmto
        FROM craplcm t
       WHERE t.cdcooper = prc_cdcooper
         AND t.nrdconta = prc_nrdconta
         AND t.cdhistor = 2386 -- Pagamento na conta
         AND t.cdbccxlt = 100
         AND TO_NUMBER(trim(replace(t.cdpesqbb,'.',''))) = prc_nrctremp
         AND t.dtmvtolt = prc_dtmvtolt
         AND t.vllanmto = prc_vllanmto;

      CURSOR c_prejuizo(pr_cdcooper craplcm.cdcooper%TYPE,
                        pr_nrdconta craplcm.nrdconta%TYPE,
                        pr_dtmvtolt craplcm.dtmvtolt%TYPE,
                      pr_nrctremp craplem.nrctremp%TYPE,
                      pr_vllanmto craplem.vllanmto%TYPE) IS
        SELECT t.vllanmto
          FROM tbcc_prejuizo_detalhe t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.cdhistor = 2781 -- Pagamento via conta transitória
           AND t.nrctremp = pr_nrctremp
           AND t.dtmvtolt = pr_dtmvtolt
           AND t.vllanmto = pr_vllanmto;

      -- Cursor para buscar o ROWID da CRAPLCM para exclusão do registro pela centralizadora
      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE,
                         pr_nrdconta IN craplcm.nrdconta%TYPE,
                         pr_nrctremp IN craplem.nrctremp%TYPE,
                       pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                       pr_vllanmto IN craplem.vllanmto%TYPE) IS
      SELECT craplcm.rowid
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.nrdconta = pr_nrdconta
         AND craplcm.dtmvtolt = pr_dtmvtolt
         AND craplcm.cdhistor = 2386 -- Pagamento na conta
         AND craplcm.cdbccxlt = 100
         AND TO_NUMBER(TRIM(REPLACE(craplcm.cdpesqbb,'.',''))) = pr_nrctremp
         AND craplcm.vllanmto = pr_vllanmto;
      rw_craplcm cr_craplcm%ROWTYPE;

      --
      CURSOR C_CRAPCYC(PR_CDCOOPER IN NUMBER
                       , PR_NRDCONTA IN NUMBER
                       , PR_NRCTREMP IN NUMBER) IS
        SELECT 1
          FROM CRAPCYC
         WHERE CDCOOPER = PR_CDCOOPER
           AND NRDCONTA = PR_NRDCONTA
           AND NRCTREMP = PR_NRCTREMP
           AND FLGEHVIP = 1
           AND CDMOTCIN = 2;
      --

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

    CURSOR cr_lancto_2781(pr_cdcooper craplem.cdcooper%TYPE
                        , pr_nrdconta craplem.nrdconta%TYPE
                        , pr_nrctremp craplem.nrctremp%TYPE
                        , pr_dtmvtolt craplem.dtmvtolt%TYPE
                        , pr_vllanmto craplem.vllanmto%TYPE) IS
    SELECT idlancto
      FROM tbcc_prejuizo_detalhe
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND dtmvtolt = pr_dtmvtolt
       AND vllanmto = pr_vllanmto
    ;
    
    CURSOR cr_crapepr(pr_cdcooper in number
                  ,pr_nrdconta in number
                  ,pr_nrctremp in number) IS
    SELECT *
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;

    vr_idlancto_2781 NUMBER;
    vr_existbpr_baixado PLS_INTEGER := 0;

    -- VARIAVEIS
    rw_crapdat     btch0001.cr_crapdat%rowtype;
    vr_erro        exception;
    vr_dscritic    varchar2(1000);
    vr_cdcritic    integer;
    vr_flgativo    integer;
    vr_nrdolote    number;
    vr_nrdrowid    rowid;
    vr_inBloqueioDebito number;

    vr_vllanmto craplcm.vllanmto%TYPE;

      EXC_LCT_NAO_EXISTE exception;
  --
  BEGIN
    -- Monta tabela de históricos de pagamento e respectivo histórico de estorno
    -- Reginaldo/AMcom - P450 - 07/12/2018
    vr_tab_historicos(2388).cdhistor := 2392;
    vr_tab_historicos(2388).dscritic := 'valor principal';
    vr_tab_historicos(2473).cdhistor := 2474;
    vr_tab_historicos(2473).dscritic := 'juros +60';
    vr_tab_historicos(2389).cdhistor := 2393;
    vr_tab_historicos(2389).dscritic := 'juros atualizacao';
    vr_tab_historicos(2390).cdhistor := 2394;
    vr_tab_historicos(2390).dscritic := 'multa atraso';
    vr_tab_historicos(2475).cdhistor := 2476;
    vr_tab_historicos(2475).dscritic := 'juros mora';
        vr_tab_historicos(2391).cdhistor := 2395;
    vr_tab_historicos(2391).dscritic := 'abono';
    vr_tab_historicos(2701).cdhistor := 2702;
    vr_tab_historicos(2701).dscritic := 'pagamento parcela';

    -- Buscar Calendário
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
    -- NÃO PERMITIR ESTORNAR CASO HAJA BAIXA DE GRAVAME
    IF vr_existbpr_baixado > 0 THEN
      vr_cdcritic := 0;
      pr_des_reto := 'NOK';
      vr_dscritic := 'Não é permitido estorno, existe baixa da alienação: ';
      raise vr_erro;
    END IF;

    IF nvl(rw_crapepr.inprejuz,0) = 0 THEN
      vr_dscritic := 'Não é permitido estorno, empréstimo não está em prejuízo: ';
      raise vr_erro;
    END IF;
    --
    vr_inBloqueioDebito := 0;
    credito.verificarBloqueioDebito(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_nrctremp => pr_nrctremp,
                                    pr_bloqueio => vr_inBloqueioDebito,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
    if vr_dscritic is not null or vr_cdcritic > 0 then
      RAISE vr_erro;
    end if;

    IF vr_inBloqueioDebito = 1 THEN
      vr_dscritic := 'Atencao! Estorno nao permitido. Bloqueio Judicial encontrado!';
      RAISE vr_erro;
    END IF;

    -- Buscar todos os lançamentos efetuados
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
        ELSIF r_craplem.cdhistor = 2389 THEN --Juros atualização
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2390 THEN --Multa atraso
          -- Atualizar o valor pago de multa
          rw_crapepr.vlpgmupr := rw_crapepr.vlpgmupr - r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2475 THEN --Juros Mora
          -- Atualizar o valor pago de juros mora
          rw_crapepr.vlpgjmpr := rw_crapepr.vlpgjmpr - r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2701 THEN
          OPEN cr_lancto_2781(pr_cdcooper => pr_cdcooper
                            , pr_nrdconta => pr_nrdconta
                            , pr_nrctremp => pr_nrctremp
                            , pr_dtmvtolt => pr_dtmvtolt
                            , pr_vllanmto => r_craplem.vllanmto);
          FETCH cr_lancto_2781 INTO vr_idlancto_2781;

          IF cr_lancto_2781%FOUND THEN
            DELETE FROM tbcc_prejuizo_detalhe
             WHERE idlancto = vr_idlancto_2781;
        END IF;

          CLOSE cr_lancto_2781;
            END IF;

        /* 1) Excluir Lancamento LEM */
        BEGIN
          DELETE FROM craplem t
              WHERE t.rowid = r_craplem.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Falha na exclusao CRAPLEM, cooper: ' || pr_cdcooper ||
                           ', conta: ' || pr_nrdconta;
            RAISE vr_erro;
        END;

      IF r_craplem.cdhistor = 2701 THEN
        /* excluir lancamento LCM */
        BEGIN

                OPEN cr_craplcm( pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctremp => pr_nrctremp,
                                 pr_dtmvtolt => r_craplem.dtmvtolt,
                                 pr_vllanmto => r_craplem.vllanmto);
                FETCH cr_craplcm INTO rw_craplcm;

                IF cr_craplcm%NOTFOUND THEN
                  if (prej0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper,
                                                      pr_nrdconta => pr_nrdconta)) then
                    delete tbcc_prejuizo_detalhe a
                    where a.cdcooper=pr_cdcooper
                      and a.nrdconta=pr_nrdconta
                      and a.cdhistor=2386;
                  else
                    CLOSE cr_craplcm;
                    vr_cdcritic := 0;
                    vr_dscritic := 'Nao foi possivel recuperar os dados do lancto para estornar:'||
                    pr_cdcooper||'/'||pr_nrdconta||'/'||pr_nrctremp||'/'||r_craplem.dtmvtolt;
                    RAISE EXC_LCT_NAO_EXISTE;
                  end if;
                END IF;

                -- Chamada da rotina centralizadora em substituição ao DELETE
                IF cr_craplcm%FOUND THEN
                   LANC0001.pc_estorna_lancto_conta(pr_cdcooper => NULL
                                                  , pr_dtmvtolt => NULL
                                                  , pr_cdagenci => NULL
                                                  , pr_cdbccxlt => NULL
                                                  , pr_nrdolote => NULL
                                                  , pr_nrdctabb => NULL
                                                  , pr_nrdocmto => NULL
                                                  , pr_cdhistor => NULL
                                                  , pr_nrctachq => NULL
                                                  , pr_nrdconta => NULL
                                                  , pr_cdpesqbb => NULL
                                                  , pr_rowid    => rw_craplcm.rowid
                                                  , pr_cdcritic => vr_cdcritic
                                                  , pr_dscritic => vr_dscritic);

                  IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                    CLOSE cr_craplcm;
                    RAISE vr_erro;
                  END IF;
                end if;

                if (prej0003.fn_verifica_preju_conta(pr_cdcooper => r_craplem.cdcooper,
                                                     pr_nrdconta => r_craplem.nrdconta))
                       and r_craplem.cdhistor = 2701 then
                   prej0003.pc_gera_cred_cta_prj (pr_cdcooper => pr_cdcooper,
                                                  pr_nrdconta => pr_nrdconta,
                                                  pr_cdoperad => '1',
                                                  pr_vlrlanc  => r_craplem.vllanmto,
                                                  pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                  pr_nrdocmto => null,
                                                  pr_cdcritic => vr_cdcritic,
                                                  pr_dscritic => vr_dscritic);
                   if (vr_cdcritic <> 0 or vr_dscritic is not null) then
                     RAISE vr_erro;
                   end if;
                end if;

                IF cr_craplcm%isopen THEN
                   CLOSE cr_craplcm;
                END IF;

        EXCEPTION
              WHEN EXC_LCT_NAO_EXISTE THEN
                RAISE vr_erro ;
          WHEN OTHERS THEN
            vr_dscritic := 'Falha na exclusao CRAPLCM, cooper: ' || pr_cdcooper ||
                           ', conta: ' || pr_nrdconta;
            RAISE vr_erro ;
        END;
        --
      END IF;
      ELSE
        -- Estorno de data anterior
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

              OPEN c_craplcm (r_craplem.cdcooper,
                                      r_craplem.nrdconta,
                                      r_craplem.dtmvtolt,
                          r_craplem.nrctremp,
                          r_craplem.vllanmto);
              FETCH c_craplcm INTO vr_vllanmto;

              IF c_craplcm%NOTFOUND THEN
                -- Reginaldo/AMcom - P450 - 07/12/2018
                OPEN c_prejuizo(r_craplem.cdcooper,
                                r_craplem.nrdconta,
                                r_craplem.dtmvtolt,
                            r_craplem.nrctremp,
                            r_craplem.vllanmto);
                FETCH c_prejuizo INTO vr_vllanmto;
                CLOSE c_prejuizo;
              END IF;

              CLOSE c_craplcm;

            IF r_craplem.cdhistor = 2701 THEN
              IF prej0003.fn_verifica_preju_conta(pr_cdcooper => r_craplem.cdcooper,
                                                  pr_nrdconta => r_craplem.nrdconta) THEN
                PREJ0003.pc_gera_cred_cta_prj (pr_cdcooper => pr_cdcooper,
                                                pr_nrdconta => pr_nrdconta,
                                                pr_cdoperad => '1',
                                                pr_vlrlanc  => vr_vllanmto,
                                                pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                pr_nrdocmto => null,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);

                IF nvl(vr_cdcritic,0) <> 0 OR trim(vr_dscritic) IS NOT NULL THEN
                   RAISE vr_erro;
                END IF;
              ELSE
            empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdagenci => r_craplem.cdagenci
                                          ,pr_cdbccxlt => 100
                                          ,pr_cdoperad => '1'
                                          ,pr_cdpactra => r_craplem.cdagenci
                                          ,pr_nrdolote => vr_nrdolote
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_cdhistor => 2387 -- EST.RECUP.PREJUIZO
                                              ,pr_vllanmto => vr_vllanmto
                                          ,pr_nrparepr => 0
                                          ,pr_nrctremp => pr_nrctremp
                                          ,pr_nrseqava => 0
                                          ,pr_idlautom => 0
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_tab_erro => vr_tab_erro );

            IF vr_des_reto <> 'OK' THEN
              IF vr_tab_erro.count() > 0 THEN
                -- Atribui críticas às variaveis
                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                vr_dscritic := 'Falha estorno Pagamento '||vr_tab_erro(vr_tab_erro.first).dscritic;
                RAISE vr_erro;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Falha ao Estornar Pagamento '||sqlerrm;
                raise vr_erro;
              END IF;
            END IF;
              END IF;

              OPEN cr_lancto_2781(pr_cdcooper => pr_cdcooper
                                , pr_nrdconta => pr_nrdconta
                                , pr_nrctremp => pr_nrctremp
                                , pr_dtmvtolt => pr_dtmvtolt
                                , pr_vllanmto => r_craplem.vllanmto);
              FETCH cr_lancto_2781 INTO vr_idlancto_2781;

              IF cr_lancto_2781%FOUND THEN
                DELETE FROM tbcc_prejuizo_detalhe
                 WHERE idlancto = vr_idlancto_2781;
            END IF;

              CLOSE cr_lancto_2781;
            END IF;

            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => r_craplem.cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => '1'
                                             ,pr_cdpactra => r_craplem.cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_tab_historicos(r_craplem.cdhistor).cdhistor
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => r_craplem.vllanmto
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => r_craplem.nrparepr
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

            IF vr_dscritic is not null THEN
              vr_dscritic := 'Ocorreu falha ao retornar gravacao LEM (' ||
                vr_tab_historicos(r_craplem.cdhistor).dscritic || '): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              raise vr_erro;
            END IF;

            --
            IF r_craplem.cdhistor IN (2391, 2701) THEN
              BEGIN
                UPDATE craplem lem
                   SET lem.dtestorn = TRUNC(rw_crapdat.dtmvtolt)
                 WHERE lem.rowid = r_craplem.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Ocorreu falha ao registrar data de estorno (' ||
                    r_craplem.cdhistor || '): ' || vr_dscritic;
                  pr_des_reto := 'NOK';
                  raise vr_erro;
              END;
        END IF;

        --
        IF r_craplem.cdhistor = 2388 THEN -- Valor Principal
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2473 THEN --Juros +60
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2389 THEN --Juros atualização
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2390 THEN --Multa atraso
          -- Atualizar o valor pago de multa
          rw_crapepr.vlpgmupr := rw_crapepr.vlpgmupr - r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2475 THEN --Juros Mora
          -- Atualizar o valor pago de juros mora
          rw_crapepr.vlpgjmpr := rw_crapepr.vlpgjmpr - r_craplem.vllanmto;
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
    /* Atualiza CRAPEPR com o valor do lançamento */
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

  EXCEPTION
    WHEN vr_erro THEN
      -- Desfazer alterações
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

         -- Retorno não OK
         GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => 'PROCESSO'
                             ,pr_dscritic => vr_dscritic
                             ,pr_dsorigem => 'INTRANET'
                             ,pr_dstransa => 'PREJ0002-Estorno pagamento.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0 --> ERRO/FALSE
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => 'crps780'
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);

  END pc_estorno_pagamento_epr_prej;
  
  -- Procedure Reponsavel por efetuar o estorno da parcela pago em dias diferentes
  PROCEDURE pc_efetua_estor_pgto_outro_dia(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                          ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                          ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                          ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                          ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                          ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                          ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                          ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                          ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE --> Data de Movimento
                                          ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                          ,pr_nrparepr IN crappep.nrparepr%TYPE --> Numero da Parcela
                                          ,pr_cdhisest IN craphis.cdhisest%TYPE --> Codigo do Historico de Estorno
                                          ,pr_vllanmto IN craplem.vllanmto%TYPE --> Valor do Lancamento
                                          ,pr_nrdrecid IN craplem.progress_recid%TYPE
                                          ,pr_dtpagemp IN craplem.dtpagemp%TYPE
                                          ,pr_txjurepr IN craplem.txjurepr%TYPE
                                          ,pr_vlpreemp IN craplem.vlpreemp%TYPE
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
  BEGIN                      
    /* .............................................................................

      Programa: pc_efetua_estor_pgto_outro_dia
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : James Prust Junior
      Data    : Setembro/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente ao Estorno de pagamento de parcelas com pagamento em Outro dia

      Observacao: 02/02/2016 - Incluso novo parametro cdorigem na chamada da procedure 
                             EMPR0001.pc_cria_lancamento_lem (Daniel) 

      Alteracoes: 
    ..............................................................................*/
    DECLARE  
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
    
      -- A cada lancamento sera gravado a data que foi realizado o estorno
      BEGIN
        UPDATE craplem
           SET craplem.dtestorn = pr_dtmvtolt
         WHERE craplem.progress_recid = pr_nrdrecid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar na tabela de craplem. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Cria o lancamento de estorno
      EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data Emprestimo
                                     ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                     ,pr_cdbccxlt => 100           --Codigo Caixa
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_cdpactra => pr_cdagenci   --Posto Atendimento
                                     ,pr_tplotmov => 5             --Tipo movimento
                                     ,pr_nrdolote => 600031        --Numero Lote
                                     ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                     ,pr_cdhistor => pr_cdhisest   --Codigo Historico                            
                                     ,pr_nrctremp => pr_nrctremp   --Numero Contrato
                                     ,pr_vllanmto => pr_vllanmto   --Valor Lancamento
                                     ,pr_dtpagemp => pr_dtpagemp   --Data Pagamento Emprestimo                            
                                     ,pr_txjurepr => pr_txjurepr   --Taxa Juros Emprestimo
                                     ,pr_vlpreemp => pr_vlpreemp   --Valor Emprestimo
                                     ,pr_nrsequni => 0             --Numero Sequencia
                                     ,pr_nrparepr => pr_nrparepr   --Numero Parcelas Emprestimo
                                     ,pr_flgincre => FALSE         --Indicador Credito
                                     ,pr_flgcredi => FALSE         --Credito                            
                                     ,pr_nrseqava => 0             --Pagamento: Sequencia do avalista
                                     ,pr_cdorigem => pr_idorigem
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Erro
                                     ,pr_dscritic => vr_dscritic); --Descricao Erro
                                     
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na EMPR0008.pc_efetua_estor_pgto_outro_dia ' || sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

    END;
          
  END pc_efetua_estor_pgto_outro_dia;  
  
  PROCEDURE pc_busca_lancamentos_pagto(pr_cdcooper            IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci            IN crapass.cdagenci%TYPE --> Código da agência
                                      ,pr_nrdcaixa            IN craperr.nrdcaixa%TYPE --> Número do caixa
                                      ,pr_cdoperad            IN crapdev.cdoperad%TYPE --> Código do Operador
                                      ,pr_nmdatela            IN VARCHAR2 --> Nome da tela
                                      ,pr_idorigem            IN INTEGER --> Id do módulo de sistema
                                      ,pr_nrdconta            IN crapepr.nrdconta%TYPE --> Número da conta
                                      ,pr_idseqttl            IN crapttl.idseqttl%TYPE --> Seq titula
                                      ,pr_nrctremp            IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                      ,pr_des_reto            OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_erro            OUT gene0001.typ_tab_erro --> Tabela com possíves erros
                                      ,pr_tab_lancto_parcelas OUT EMPR0008.typ_tab_lancto_parcelas) IS --> Tabela com registros de estorno
  BEGIN                      
   
    DECLARE
    
      -- Cursor do Emprestimo
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE,
                        pr_nrdconta IN crapepr.nrdconta%TYPE,
                        pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crapepr.inprejuz,
               crapepr.dtultpag,
               crapepr.dtliquid,
               crapepr.dtultest,
               crapepr.tpemprst,
               crapepr.tpdescto, --P437
               crapepr.flgpagto,
               crapepr.cdlcremp,
               crapepr.inliquid,
               crapepr.cdfinemp,
               crawepr.dtvencto,
               crawepr.idquapro,
               crawepr.dtlibera,
               crawepr.flgreneg
          FROM crapepr
          
          JOIN crawepr ON crawepr.cdcooper = crapepr.cdcooper
                      AND crawepr.nrdconta = crapepr.nrdconta
                      AND crawepr.nrctremp = crapepr.nrctremp
          
         WHERE crapepr.cdcooper = pr_cdcooper 
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      -- Cursor da Linha de Credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE,
                        pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT tpctrato
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper 
           AND craplcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      
      -- Cursor da Finalidade
      CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE,
                        pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
        SELECT tpfinali
          FROM crapfin
         WHERE crapfin.cdcooper = pr_cdcooper 
           AND crapfin.cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;
      
      -- Cursor da Parcela do Emprestimo
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE,
                        pr_nrdconta IN crappep.nrdconta%TYPE,
                        pr_nrctremp IN crappep.nrctremp%TYPE,
                        pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT dtvencto
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper 
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Cursor para buscar os bens do emprestimo
      CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE,
                        pr_nrdconta IN crapbpr.nrdconta%TYPE,
                        pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
        SELECT cdsitgrv,
               tpdbaixa
          FROM crapbpr
         WHERE crapbpr.cdcooper = pr_cdcooper
           AND crapbpr.nrdconta = pr_nrdconta
           AND crapbpr.nrctrpro = pr_nrctremp
           AND crapbpr.tpctrpro in (90,99);
               
      -- Cursor dos Lancamentos do Emprestimo
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE,
                        pr_nrdconta IN craplem.nrdconta%TYPE,
                        pr_nrctremp IN craplem.nrctremp%TYPE,     
                        pr_dtmvtolt IN craplem.dtmvtolt%TYPE,
                        pr_dtultest IN crapepr.dtultest%TYPE) IS
        select aux.*, sum(aux.vllanmto) OVER (PARTITION BY nrparepr) vlpagpar  
          from (SELECT craplem.nrdconta,
               craplem.nrctremp,
               craplem.nrparepr,
               craplem.dtmvtolt,
               craplem.cdhistor,
               craplem.vllanmto,
               craplem.dtpagemp,
               craplem.txjurepr,
               craplem.vlpreemp,
               craphis.cdhisest,
               craplem.progress_recid        
                    FROM craplem,
                         craphis,
                         crapepr
                   WHERE craphis.cdcooper = craplem.cdcooper
           AND craphis.cdhistor = craplem.cdhistor
                     AND craplem.cdcooper = crapepr.cdcooper
                     AND craplem.nrdconta = crapepr.nrdconta
                     AND craplem.nrctremp = crapepr.nrctremp
                     AND crapepr.tpemprst||crapepr.tpdescto <> 12 --Consignado - PP - Desconto em Folha
                     AND craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.dtmvtolt = pr_dtmvtolt                      
           AND (nvl(pr_dtultest,SYSDATE) = SYSDATE OR craplem.dtmvtolt >= pr_dtultest)
           AND craplem.nrparepr > 0    
           AND craphis.cdhisest > 0
           AND craplem.dthrtran >= pr_dtinilan
           AND craplem.dthrtran <= pr_dtfinlan
       AND craphis.cdhistor NOT IN (2311,2312) -- IOF Atraso 
                UNION
                SELECT craplem.nrdconta,
                       craplem.nrctremp,
                       craplem.nrparepr,
                       craplem.dtmvtolt,
                       craplem.cdhistor,
                       craplem.vllanmto,
                       craplem.dtpagemp,
                       craplem.txjurepr,
                       craplem.vlpreemp,
                       craphis.cdhisest,
                       craplem.progress_recid        
                  FROM craplem,
                       craphis,
                       crapepr
                 WHERE craphis.cdcooper = craplem.cdcooper
                   AND craphis.cdhistor = craplem.cdhistor
                   AND craplem.cdcooper = crapepr.cdcooper
                   AND craplem.nrdconta = crapepr.nrdconta
                   AND craplem.nrctremp = crapepr.nrctremp
                   AND crapepr.tpemprst||crapepr.tpdescto = 12 --Consignado - PP - Desconto em Folha
                   AND craplem.cdcooper = pr_cdcooper
                   AND craplem.nrdconta = pr_nrdconta
                   AND craplem.nrctremp = pr_nrctremp
                   AND craplem.dtmvtolt = pr_dtmvtolt                      
                   AND (nvl(pr_dtultest,SYSDATE) = SYSDATE OR craplem.dtmvtolt >= pr_dtultest)
                   AND craplem.nrparepr > 0    
                   AND craphis.cdhisest > 0
                   AND craphis.cdhistor NOT IN (2311,2312) -- IOF Atraso
                 UNION
                  --P437-CONSIGNADO
                  SELECT consig_pg.nrdconta,
                         consig_pg.nrctremp,
                         consig_pg.nrparepr,
                         crapepr.dtultpag   dtmvtolt,
                         craplcm.cdhistor,
                         craplcm.vllanmto,
                         crappep.dtultpag   dtpagemp,
                         NULL txjurepr,  
                         consig_pg.vlparepr vlpreemp,
                         craphis.cdhisest,
                         consig_pg.idsequencia progress_recid      
                  FROM tbepr_consignado_pagamento consig_pg,
                       crapepr crapepr,
                       crappep crappep,
                       craplcm craplcm,
                       craphis craphis,
                       crapdat crapdat
                  WHERE consig_pg.cdcooper = crapepr.cdcooper
                    AND consig_pg.nrdconta = crapepr.nrdconta
                    AND consig_pg.nrctremp = crapepr.nrctremp
                    AND crapepr.tpemprst   = 1  --Empréstimo PP - Consignado
                    AND crapepr.tpdescto   = 2  --Folha de Pagamento - Consignado
                    AND crapepr.dtultpag   = crappep.dtultpag
                    AND consig_pg.cdcooper = crappep.cdcooper
                    AND consig_pg.nrdconta = crappep.nrdconta
                    AND consig_pg.nrctremp = crappep.nrctremp
                    AND consig_pg.nrparepr = crappep.nrparepr         
                   AND consig_pg.cdcooper = crapdat.cdcooper
                    --    
                    --AND craplcm.vllanmto = consig_pg.vlpagpar
                    AND craplcm.cdcooper = consig_pg.cdcooper
                    AND craplcm.nrdconta = consig_pg.nrdconta
                    AND craplcm.cdpesqbb = gene0002.fn_mask(consig_pg.nrctremp, 'zz.zzz.zz9')
                    AND craplcm.nrparepr = consig_pg.nrparepr
                    AND craplcm.dtmvtolt = pr_dtmvtolt--data do ultimo pagamento
                   AND craplcm.dtmvtolt = crapdat.dtmvtolt -- A LCM precisa ser da data atual
                    AND craplcm.cdbccxlt = 100
                   AND craplcm.cdhistor in( 108,1539,  -- PAGAMENTO
                                            3089,3190, -- SM09_2 - PAGTO PRESTACAO DE EMPRESTIMO CONSIGNADO
                                             1060,1070, -- Multa
                                             1071,1072, -- Mora/Atraso
                                             2313,2314, -- IOF 
                                             1050,1051, -- Juros de Atraso
                                             1048,1049) -- Valor de Desconto 
                    --
                    AND craphis.cdhistor = craplcm.cdhistor
                    AND craphis.cdcooper = craplcm.cdcooper
                    AND craphis.cdhisest > 0
                    --
                    AND consig_pg.instatus = 2 --processado
                   AND consig_pg.Inorgpgt <> 5 --Conciliacao
                    AND consig_pg.idseqpagamento IS NULL --Registro de Pagamento
                    AND consig_pg.cdcooper = pr_cdcooper
                    AND consig_pg.nrdconta = pr_nrdconta
                    AND consig_pg.nrctremp = pr_nrctremp         
                  ORDER BY nrctremp,nrparepr, dtmvtolt
                  ) aux;
          
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      
      vr_nrdiaest      PLS_INTEGER;
      vr_ind_estorno   VARCHAR(20);
      vr_dtliquid      DATE;
      vr_dstextab      craptab.dstextab%TYPE;
      vr_dtvenmes      DATE;

    BEGIN
      pr_tab_lancto_parcelas.DELETE;  
    
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
                                      
      -- Busca os dados do emprestimo
      OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      -- Verifica se a retornou registro
      IF cr_crapepr%NOTFOUND THEN
        CLOSE cr_crapepr;
        vr_cdcritic := 356;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_crapepr;
      END IF;

      -- Nao pode 
      IF rw_crapepr.flgreneg = 1 THEN
        vr_dscritic := 'Nao e permitido efetuar o estorno de um contrato renegociado';
        RAISE vr_exc_saida;
      END IF;
      
      -- Somente o produto PP ira ter estorno
      IF rw_crapepr.tpemprst <> 1 THEN
        vr_cdcritic := 946;
        RAISE vr_exc_saida;
      END IF;
      
      -- Contrato de Emprestimo nao pode estar em Prejuizo
      IF rw_crapepr.inprejuz <> 0 THEN
        vr_dscritic := 'Nao e permitido efetuar o estorno de um contrato em prejuizo';
        RAISE vr_exc_saida;
      END IF;
      
      -- Contrato de emprestimo nao pode debitar em Folha
      IF rw_crapepr.flgpagto <> 0 AND
         rw_crapepr.tpemprst <> 1 AND   --P437 --Validação do Consignado Antigo
         rw_crapepr.tpdescto <> 2 THEN  --P437 
        vr_dscritic := 'Nao e permitido efetuar o estorno de um contrato em folha';
        RAISE vr_exc_saida;
      END IF;
      
      -- O ultimo pagamento precisa estar dentro do mês
      IF NOT(rw_crapepr.dtultpag >= rw_crapdat.dtinimes AND rw_crapepr.dtultpag <= rw_crapdat.dtultdia) THEN
        vr_dscritic := 'A data do ultimo pagamento deve estar dentro do mes';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca os dados da linha de credito
      OPEN cr_craplcr (pr_cdcooper => pr_cdcooper
                      ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- Verifica se a retornou registro
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        vr_dscritic := 'Linha de credito nao cadastrada. Codigo: ' || TO_CHAR(rw_crapepr.cdlcremp);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_craplcr;
      END IF;
      
      -- Emprestimo/Financiamento, Alienacao de Veiculo, Hipoteca de Imoveis, Aplicacao
      IF rw_craplcr.tpctrato NOT IN (1,2,3,4) THEN
        vr_dscritic := 'Tipo de contrato da linha de credito nao permitida';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca os dados da Finalidade
      OPEN cr_crapfin (pr_cdcooper => pr_cdcooper
                      ,pr_cdfinemp => rw_crapepr.cdfinemp);
      FETCH cr_crapfin INTO rw_crapfin;
      -- Verifica se a retornou registro
      IF cr_crapfin%NOTFOUND THEN
        CLOSE cr_crapfin;
        vr_dscritic := 'Finalidade nao cadastrada. Codigo: ' || TO_CHAR(rw_crapepr.cdfinemp);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_crapfin;
      END IF;
      
      -- Emprestimo/Financiamento nao pode ser do tipo Portabilidade
      /* 31/01/2018 #826621 - Conforme posicionamento da área, os contratos de portabilidade também
         poderão ser estornados. Regra retirada do sistema.
      IF rw_crapfin.tpfinali = 2 THEN
        vr_dscritic := 'Nao e permitido efetuar o estorno, contrato de portabilidade';
        RAISE vr_exc_saida;
      END IF; */
     
      -- Caso o contrato de emprestimo estiver liquidado, precisamos fazer algumas validacoes  
      IF rw_crapepr.inliquid = 1 THEN
        
        -- A data de liquidacao precisa estar dentro do mês
        IF NOT(rw_crapepr.dtliquid >= rw_crapdat.dtinimes AND rw_crapepr.dtliquid <= rw_crapdat.dtultdia) THEN
          vr_dscritic := 'Nao e permitido efetuar o estorno, pois a liquidacao esta fora do mes';
          RAISE vr_exc_saida;
        END IF;
        
        -- Alienacao de Veiculo  
        IF rw_craplcr.tpctrato = 2 THEN
        
          -- Vamos verificar se os bens estao alienados ao contrato
          FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_nrctremp => pr_nrctremp) LOOP            
             
            IF UPPER(rw_crapbpr.tpdbaixa) = 'M' THEN
              vr_dscritic := 'Nao e possivel efetuar o estorno, contrato liquidado.';
              RAISE vr_exc_saida;
            END IF;
            
            IF rw_crapbpr.cdsitgrv NOT IN (0,2) THEN
              vr_dscritic := 'Nao e possivel efetuar o estorno, Gravames em processamento, verifique a tela Gravam.';
              RAISE vr_exc_saida;
            END IF; /* END IF rw_crapbpr.cdsitgrv NOT IN (0,2) THEN */
            
          END LOOP; /* END FOR rw_crapbpr */
          
        -- Alienacao/Hipoteca de Imoveis
        ELSIF rw_craplcr.tpctrato = 3 THEN
          
          vr_nrdiaest := 0;
          vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'USUARI'
                                                   ,pr_cdempres => 11
                                                   ,pr_cdacesso => 'PAREMPREST'
                                                   ,pr_tpregist => 1);
          --Se nao encontrou parametro
          IF TRIM(vr_dstextab) IS NULL THEN
            vr_cdcritic := 55;
            RAISE vr_exc_saida;
          ELSE
            vr_nrdiaest := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 9, 3)),0);

          END IF;
          
          -- Retorna a data de liquidacao somado com os dias configurados
          vr_dtliquid := EMPR0008.fn_retorna_data_util(pr_cdcooper => pr_cdcooper,
                                              pr_dtiniper => rw_crapepr.dtliquid,
                                              pr_qtdialib => vr_nrdiaest);
          
          -- A data de liquidacao nao pode ser maior que os dias configurados
          IF NOT(vr_dtliquid >= rw_crapdat.dtmvtolt) THEN
            vr_dscritic := 'Nao e possivel efetuar o estorno, contrato liquidado.';
            RAISE vr_exc_saida;
          END IF;
          
        END IF; /* END IF rw_crapepr.tpctrato = 3 THEN */
        
      END IF;
      
      /* Calcular o vencimento dentro do mês */
      vr_dtvenmes := TO_DATE(TO_CHAR(rw_crapepr.dtvencto, 'DD') || 
                           TO_CHAR(rw_crapdat.dtmvtolt, 'MMYYYY'), 'DDMMYYYY'); 
      /* Regra para não permitir estornar pagamentos antes do vencimento no mês 
      que no dia do vencimento não ocorreu nenhum pagamento, irá gerar residuo
      no contrato será avaliada uma solução definitiva posteriormente */  
      IF  (rw_crapdat.dtmvtolt > vr_dtvenmes)
      AND (rw_crapepr.dtultpag < vr_dtvenmes) 
      -- garantir que irá permitir estorno dentro da carencia - Rafael Maciel (RKAM)
      AND ( (rw_crapepr.dtvencto < rw_crapdat.dtmvtolt) 
          AND (rw_crapepr.tpemprst = 1)
          AND (rw_crapepr.idquapro = 0)
          AND (rw_crapepr.dtlibera > rw_crapdat.dtmvtolt)
      ) THEN
          vr_dscritic := 'Contrato nao pode ser estornado.';
          RAISE vr_exc_saida;
      END IF; 

      -- Vamos buscar todos os lancamentos que podem ser estornados
      FOR rw_craplem IN cr_craplem(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp,
                                   pr_dtmvtolt => rw_crapepr.dtultpag,
                                   pr_dtultest => rw_crapepr.dtultest) LOOP            
                                   
        -- Busca os dados da parcela
        OPEN cr_crappep (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrctremp => pr_nrctremp,
                         pr_nrparepr => rw_craplem.nrparepr);
        FETCH cr_crappep INTO rw_crappep;
        -- Verifica se a retornou registro
        IF cr_crappep%NOTFOUND THEN
          CLOSE cr_crappep;
          vr_dscritic := 'Parcela nao encontrada'               ||
                         '. Conta: '    || TO_CHAR(pr_nrdconta) ||
                         '. Contrato: ' || TO_CHAR(pr_nrctremp) ||
                         '. Parcela: '  || TO_CHAR(rw_craplem.nrparepr);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas Fecha o Cursor
          CLOSE cr_crappep;
        END IF;
        
        
        vr_ind_estorno := pr_tab_lancto_parcelas.COUNT() + 1;
        pr_tab_lancto_parcelas(vr_ind_estorno).cdcooper := pr_cdcooper;
        pr_tab_lancto_parcelas(vr_ind_estorno).nrdconta := pr_nrdconta;
        pr_tab_lancto_parcelas(vr_ind_estorno).nrctremp := pr_nrctremp;
        pr_tab_lancto_parcelas(vr_ind_estorno).nrparepr := rw_craplem.nrparepr;
        pr_tab_lancto_parcelas(vr_ind_estorno).dtmvtolt := rw_craplem.dtmvtolt;
        pr_tab_lancto_parcelas(vr_ind_estorno).cdhistor := rw_craplem.cdhistor;
        pr_tab_lancto_parcelas(vr_ind_estorno).dtvencto := rw_crappep.dtvencto;
        pr_tab_lancto_parcelas(vr_ind_estorno).vllanmto := rw_craplem.vllanmto;
        pr_tab_lancto_parcelas(vr_ind_estorno).nrdrecid := rw_craplem.progress_recid;
        pr_tab_lancto_parcelas(vr_ind_estorno).flgestor := TRUE;        
        pr_tab_lancto_parcelas(vr_ind_estorno).dtpagemp := rw_craplem.dtpagemp;
        pr_tab_lancto_parcelas(vr_ind_estorno).txjurepr := NVL(rw_craplem.txjurepr,0);
        pr_tab_lancto_parcelas(vr_ind_estorno).vlpreemp := NVL(rw_craplem.vlpreemp,0);
        pr_tab_lancto_parcelas(vr_ind_estorno).vlpagpar := NVL(rw_craplem.vlpagpar,0);
        
        /* Regra definida pelo Oscar, caso o Historico for igual ao historico de Estorno
           nao sera realizado o estorno do lancamento                                    */
        IF rw_craplem.cdhistor = rw_craplem.cdhisest THEN
          pr_tab_lancto_parcelas(vr_ind_estorno).flgestor := FALSE;
        END IF;
        
      END LOOP; -- END FOR rw_craplem
      
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
       
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';                     
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na EMPR0008.pc_busca_lancamentos_pagto ' || sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

    END;
    
  END pc_busca_lancamentos_pagto;
  
  
  
  PROCEDURE pc_tela_estornar_pagamentos_PP(pr_cdcooper IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                                           ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                           ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                           ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                           ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                           ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                                           ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                           ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE --> Movimento atual
                                           ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                           ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
                                           ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da Critica
                                           ,pr_dscritic OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    
    DECLARE
      -- Cursor do Lancamento do Emprestimo
      CURSOR cr_craplem_max(pr_cdcooper IN craplem.cdcooper%TYPE,
                            pr_nrdconta IN craplem.nrdconta%TYPE,
                            pr_nrctremp IN craplem.nrctremp%TYPE,
                            pr_nrparepr IN craplem.nrparepr%TYPE) IS
        SELECT MAX(craplem.dtmvtolt) as dtmvtolt
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.nrparepr = pr_nrparepr
           AND craplem.dtestorn IS NULL
           AND craplem.cdhistor IN (1039,1044,1045,1057);
      
      /* Cursor para buscar o lancamento de Juros Remuneratorio */
      CURSOR cr_craplem_juros(pr_cdcooper IN craplem.cdcooper%TYPE,
                              pr_nrdconta IN craplem.nrdconta%TYPE,
                              pr_nrctremp IN craplem.nrctremp%TYPE,
                              pr_nrparepr IN craplem.nrparepr%TYPE,
                              pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
        SELECT craplem.vllanmto,
               count(1) over() qtde_registro
          FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.nrparepr = pr_nrparepr
           AND craplem.dtmvtolt = pr_dtmvtolt
           AND craplem.cdhistor IN (1050,1051);
      rw_craplem_juros cr_craplem_juros%ROWTYPE;     
      
      -- Cursor para buscar a ultima parcela que foi paga
      CURSOR cr_crappep_max_pagto(pr_cdcooper IN crappep.cdcooper%TYPE,
                                  pr_nrdconta IN crappep.nrdconta%TYPE,
                                  pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT MAX(crappep.dtultpag) dtultpag
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp;
      vr_dtultpag crappep.dtultpag%TYPE;
      
      -- Cursor para buscar a primeira parcela que nao foi paga
      CURSOR cr_crappep_min_dtvencto(pr_cdcooper IN crappep.cdcooper%TYPE,
                                     pr_nrdconta IN crappep.nrdconta%TYPE,
                                     pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT MIN(crappep.dtvencto) dtvencto
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.inliquid = 0;
      vr_dtvencto crappep.dtvencto%TYPE;     
      
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE,
                        pr_nrdconta IN crappep.nrdconta%TYPE,
                        pr_nrctremp IN crappep.nrctremp%TYPE,
                        pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT inliquid,
               dtultpag
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      
      -- Cursor para buscar os bens do emprestimo
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
      
      -- Cursor para o historico do lancamento     
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE,
                        pr_cdhistor IN craphis.cdhistor%TYPE) IS
        SELECT cdhisest
          FROM craphis
         WHERE craphis.cdcooper = pr_cdcooper
           AND craphis.cdhistor = pr_cdhistor;
      vr_cdhisest craphis.cdhisest%TYPE;
           
      -- Verifica se alguma parcela ficou com saldo negativo
      CURSOR cr_crappep_saldo(pr_cdcooper IN crappep.cdcooper%TYPE,
                              pr_nrdconta IN crappep.nrdconta%TYPE,
                              pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT 1
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND (crappep.vlpagpar < 0 OR
                crappep.vlsdvpar < 0 OR
                crappep.vlsdvsji < 0 OR
                crappep.vldespar < 0 OR
                crappep.vlpagmra < 0 OR
                crappep.vlpagmta < 0);                       
      vr_flgnegat PLS_INTEGER := 0;
           
      -- Cursor para verificar se é um Emprestimo Consigado - P437
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE,
                        pr_nrdconta IN crapepr.nrdconta%TYPE,
                        pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT 1
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp
           AND crapepr.tpemprst = 1
           AND crapepr.tpdescto = 2;
      vr_flgconsig PLS_INTEGER := 0;
           
      vr_tab_erro                  GENE0001.typ_tab_erro;
      vr_tab_lancto_parcelas       EMPR0008.typ_tab_lancto_parcelas;
      vr_tab_lancto_cc             EMPR0001.typ_tab_lancconta;
      vr_cdestorno                 tbepr_estorno.cdestorno%TYPE;
      vr_cdlancamento              tbepr_estornolancamento.cdlancamento%TYPE;
      vr_vlpagpar                  crappep.vlpagpar%TYPE;
      vr_vlpagmta                  crappep.vlpagmta%TYPE;
      vr_vlpagmra                  crappep.vlpagmra%TYPE;
      vr_vljuratr                  craplem.vllanmto%TYPE;
      vr_vldescto                  craplem.vllanmto%TYPE;      
      vr_dtmvtolt                  DATE;      
      vr_index_lanc                VARCHAR2(80);
      vr_cdhislcm                  PLS_INTEGER;
      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_des_reto      VARCHAR2(3);

    BEGIN
      vr_tab_erro.DELETE;
      vr_tab_lancto_parcelas.DELETE;
      vr_tab_lancto_cc.DELETE;
           
      -- Cursor para verificar se é um Empréstimo Consignado - P437
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr
       INTO vr_flgconsig;
      CLOSE cr_crapepr;
      
      --Se for Consignado - P437
      IF nvl(vr_flgconsig,0) = 1 THEN  
        vr_cdcritic := 0;
        vr_dscritic := 'Estorno Pagamento de consignado nao pode ser efetuado por este programa.';
        RAISE vr_exc_saida;
      END IF;  
           
      -- Busca os lancamento que podem ser estornados para o contrato informado                     
      pc_busca_lancamentos_pagto(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_idorigem => pr_idorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro
                                ,pr_tab_lancto_parcelas => vr_tab_lancto_parcelas);
                                           
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Buscar o erro encontrado para gravar na vr_des_erro
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;
            
      IF vr_tab_lancto_parcelas.count = 0 THEN
        vr_dscritic := 'A data do ultimo pagamento deve estar dentro do mes';
        RAISE vr_exc_saida;
      END IF;  
            
      --Cria o registro do Estorno
      BEGIN
        INSERT INTO tbepr_estorno
          (cdcooper
          ,cdestorno
          ,nrdconta
          ,nrctremp
          ,cdoperad
          ,cdagenci
          ,dtestorno
          ,hrestorno
          ,dsjustificativa)
        VALUES
          (pr_cdcooper
          ,fn_sequence('TBEPR_ESTORNO','CDESTORNO',pr_cdcooper)
          ,pr_nrdconta
          ,pr_nrctremp
          ,pr_cdoperad
          ,pr_cdagenci
          ,pr_dtmvtolt
          ,gene0002.fn_busca_time
          ,pr_dsjustificativa)
          RETURNING tbepr_estorno.cdestorno INTO vr_cdestorno;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir na tabela de tbepr_estorno. ' ||SQLERRM;
          RAISE vr_exc_saida;
      END;      
      
      -- Cursor para verificar se precisa fazer as baixas dos bens
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
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            RAISE vr_exc_saida;
          END IF;  
        END IF;
        
      END IF; -- END IF NVL(vr_existbpr,0) > 0 THEN
        
      -- Percorre todos os lancamentos de acordo com a data de movimento
      FOR idx IN vr_tab_lancto_parcelas.FIRST..vr_tab_lancto_parcelas.LAST LOOP
        vr_cdhislcm := 0; -- Historico de lancamento na conta corrente
        vr_vlpagpar := 0; -- Valor do Pagamento
        vr_vlpagmta := 0; -- Valor Pago na Multa
        vr_vlpagmra := 0; -- Valor Pago no Juros de Mora
        vr_vljuratr := 0; -- Valor do Juros em Atraso
        vr_vldescto := 0; -- Valor de Desconto
        
        -- Busca os dados da parcela
        OPEN cr_crappep (pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                         pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                         pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp,
                         pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr);
        FETCH cr_crappep INTO rw_crappep;
        -- Verifica se a retornou registro
        IF cr_crappep%NOTFOUND THEN
          CLOSE cr_crappep;
          vr_dscritic := 'Parcela nao encontrada' ||
                         '. Conta: '    || TO_CHAR(vr_tab_lancto_parcelas(idx).nrdconta) ||
                         '. Contrato: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).nrctremp) ||
                         '. Parcela: '  || TO_CHAR(vr_tab_lancto_parcelas(idx).nrparepr);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas Fecha o Cursor
          CLOSE cr_crappep;
        END IF;
        
        -- Vamos verificar se o historico do lancamento possui historico de estorno cadastrado
        OPEN cr_craphis (pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                         pr_cdhistor => vr_tab_lancto_parcelas(idx).cdhistor);
        FETCH cr_craphis
         INTO vr_cdhisest;
        CLOSE cr_craphis;
        
        IF NVL(vr_cdhisest,0) = 0 THEN
          vr_dscritic := 'Historico nao possui codigo de estorno cadastrado. Historico: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).cdhistor);
          RAISE vr_exc_saida;
        END IF;
        
        -- Verifica se o historico eh pagamento
        IF vr_tab_lancto_parcelas(idx).cdhistor IN (1039,1044,1045,1057) THEN
          -- Valor do Pagamento da Parcela
          vr_vlpagpar := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor IN (1045,1057) THEN
            vr_cdhislcm := 1539;
          ELSE
            vr_cdhislcm := 108;
          END IF;
          
        -- Juros de Mora
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1619,1077,1620,1078) THEN
          vr_vlpagmra := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor = 1619 THEN
            vr_cdhislcm := 1543;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1077 THEN
            vr_cdhislcm := 1071;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1620 THEN
            vr_cdhislcm := 1544;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1078 THEN
            vr_cdhislcm := 1072;
          END IF;
          
        -- Multa
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1540,1047,1618,1076) THEN
          vr_vlpagmta := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor = 1540 THEN
            vr_cdhislcm := 1541;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1047 THEN
            vr_cdhislcm := 1060;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1618 THEN
            vr_cdhislcm := 1542;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1076 THEN
            vr_cdhislcm := 1070;
          END IF;
          
        -- Juros de Atraso  
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1050,1051) THEN
          vr_vljuratr := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          
        -- Valor de Desconto
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1048,1049) THEN
          vr_vldescto := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          
        ELSE
          vr_dscritic := 'Historico nao permitido para efetuar o estorno. Codigo: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).cdhistor);
          RAISE vr_exc_saida;
          
        END IF;
        
        -- Atualiza os dados da Parcela
        BEGIN
          UPDATE crappep
             SET crappep.vlpagpar = nvl(crappep.vlpagpar,0) - nvl(vr_vlpagpar,0)
                ,crappep.vlsdvpar = nvl(crappep.vlsdvpar,0) + nvl(vr_vlpagpar,0) - nvl(vr_vljuratr,0) + nvl(vr_vldescto,0)
                ,crappep.vlsdvsji = nvl(crappep.vlsdvsji,0) + nvl(vr_vlpagpar,0) - nvl(vr_vljuratr,0) + nvl(vr_vldescto,0)
                ,crappep.vldespar = nvl(crappep.vldespar,0) - nvl(vr_vldescto,0)
                ,crappep.vlpagjin = nvl(crappep.vlpagjin,0) - nvl(vr_vljuratr,0)
                ,crappep.inliquid = 0            
                ,crappep.vlpagmra = nvl(crappep.vlpagmra,0) - nvl(vr_vlpagmra,0)
                ,crappep.vlpagmta = nvl(crappep.vlpagmta,0) - nvl(vr_vlpagmta,0)
           WHERE crappep.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND crappep.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND crappep.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp
             AND crappep.nrparepr = vr_tab_lancto_parcelas(idx).nrparepr;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crappep. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Atualiza os dados do Emprestimo
        BEGIN
          UPDATE crapepr
             SET crapepr.vlsdeved = crapepr.vlsdeved + vr_vlpagpar,
                 crapepr.qtprepag = crapepr.qtprepag - DECODE(rw_crappep.inliquid,1,1,0),
                 crapepr.qtprecal = crapepr.qtprepag - DECODE(rw_crappep.inliquid,1,1,0),
                 crapepr.dtultest = pr_dtmvtolt,
                 crapepr.dtliquid = NULL
           WHERE crapepr.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND crapepr.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND crapepr.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crapepr. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        /* Lancamentos de Desconto e Juros de Atraso, sera apenas atualizado a data de estorno */
        IF vr_tab_lancto_parcelas(idx).flgestor = FALSE THEN
          BEGIN
            UPDATE craplem
               SET craplem.dtestorn = pr_dtmvtolt
             WHERE craplem.progress_recid = vr_tab_lancto_parcelas(idx).nrdrecid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar a tabela craplem. ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
          
          -- Pula para o proximo lancamento
          CONTINUE;
        END IF;
        
        -- Sequencia da tabela de pagamentos das parcelas
        vr_cdlancamento := fn_sequence('TBEPR_ESTORNOLANCAMENTO','CDLANCAMENTO',pr_cdcooper                          || ';' || 
                                                                                vr_tab_lancto_parcelas(idx).nrdconta || ';' || 
                                                                                vr_tab_lancto_parcelas(idx).nrctremp || ';' ||
                                                                                vr_cdestorno);

        BEGIN
          INSERT INTO tbepr_estornolancamento
            (cdcooper
            ,nrdconta
            ,nrctremp
            ,cdestorno
            ,cdlancamento
            ,nrparepr
            ,dtvencto
            ,dtpagamento
            ,vllancamento
            ,cdhistor)
          VALUES
            (pr_cdcooper
            ,vr_tab_lancto_parcelas(idx).nrdconta
            ,vr_tab_lancto_parcelas(idx).nrctremp
            ,vr_cdestorno
            ,vr_cdlancamento
            ,vr_tab_lancto_parcelas(idx).nrparepr
            ,vr_tab_lancto_parcelas(idx).dtvencto
            ,vr_tab_lancto_parcelas(idx).dtmvtolt
            ,vr_tab_lancto_parcelas(idx).vllanmto
            ,vr_tab_lancto_parcelas(idx).cdhistor);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir na tabela de tbepr_estornolancamento. ' ||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Condicao para estornar o pagamento efetuado no mesmo dia
        IF vr_tab_lancto_parcelas(idx).dtmvtolt = pr_dtmvtolt THEN  
 
          EMPR0008.pc_efetua_estor_pgto_no_dia(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nmdatela => pr_nmdatela
                                     ,pr_idorigem => pr_idorigem
                                     ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta
                                     ,pr_idseqttl => pr_idseqttl
                                     ,pr_dtmvtolt => vr_tab_lancto_parcelas(idx).dtmvtolt
                                     ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp
                                     ,pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr
                                     ,pr_des_reto => vr_des_reto
                                     ,pr_tab_erro => vr_tab_erro);
                                     
          IF vr_des_reto = 'NOK' THEN
            IF vr_tab_erro.COUNT > 0 THEN
              -- Buscar o erro encontrado para gravar na vr_des_erro
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              RAISE vr_exc_saida;
            END IF;   
          END IF;
        
        -- Condicao para estornar o pagamento retroativo
        ELSE
          
          pc_efetua_estor_pgto_outro_dia(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nmdatela => pr_nmdatela
                                        ,pr_idorigem => pr_idorigem
                                        ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp
                                        ,pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr
                                        ,pr_cdhisest => vr_cdhisest
                                        ,pr_vllanmto => vr_tab_lancto_parcelas(idx).vllanmto
                                        ,pr_nrdrecid => vr_tab_lancto_parcelas(idx).nrdrecid
                                        ,pr_dtpagemp => vr_tab_lancto_parcelas(idx).dtpagemp
                                        ,pr_txjurepr => vr_tab_lancto_parcelas(idx).txjurepr
                                        ,pr_vlpreemp => vr_tab_lancto_parcelas(idx).vlpreemp
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_tab_erro => vr_tab_erro);
                                     
          IF vr_des_reto = 'NOK' THEN
            IF vr_tab_erro.COUNT > 0 THEN
              -- Buscar o erro encontrado para gravar na vr_des_erro
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              RAISE vr_exc_saida;
            END IF;
          END IF;
          
          -- Armazena o Valor estornado para fazer um unico lancamento em Conta Corrente
          empr0008.pc_cria_atualiza_ttlanconta (pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper --> Cooperativa conectada
                                      ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp --> Número do contrato de empréstimo
                                      ,pr_cdhistor => vr_cdhislcm                          --> Codigo Historico
                                      ,pr_dtmvtolt => pr_dtmvtolt                          --> Movimento atual
                                      ,pr_cdoperad => pr_cdoperad                          --> Código do Operador
                                      ,pr_cdpactra => pr_cdagenci                          --> P.A. da transação                                       
                                      ,pr_nrdolote => 600031                               --> Numero do Lote
                                      ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta --> Número da conta
                                      ,pr_vllanmto => vr_tab_lancto_parcelas(idx).vllanmto --> Valor lancamento
                                      ,pr_nrseqava => 0                                    --> Pagamento: Sequencia do avalista
                                      ,pr_tab_lancconta => vr_tab_lancto_cc                --> Tabela Lancamentos Conta
                                      ,pr_des_erro => vr_des_reto                          --> Retorno OK / NOK
                                      ,pr_dscritic => vr_dscritic);                        --> descricao do erro
                                      
          IF vr_des_reto = 'NOK' THEN
            RAISE vr_exc_saida;
          END IF;
          
        END IF; 
        
        -- Inicio -- PRJ577 -- EST25314
        IF empr0021.fn_contrato_renegociado(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper
                                           ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta
                                           ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp
                                           ) THEN
        
          empr0021.pc_estorna_sld_ctr_renegociado(pr_dtpagmto => vr_tab_lancto_parcelas(idx).dtpagemp
                                                 ,pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper
                                                 ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta
                                                 ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic
                                                 );
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        
        END IF;
        -- Fim -- PRJ577 -- EST25314

        -- Busca a data do ultimo pagamento da parcela
        OPEN cr_craplem_max(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                            pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                            pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp,
                            pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr);
        FETCH cr_craplem_max
         INTO vr_dtultpag;
        CLOSE cr_craplem_max;
        
        -- Atualiza a data de pagamento da ultima parcela paga
        BEGIN
          UPDATE crappep
             SET crappep.dtultpag = vr_dtultpag
           WHERE crappep.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND crappep.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND crappep.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp
             AND crappep.nrparepr = vr_tab_lancto_parcelas(idx).nrparepr;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crappep. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
      END LOOP; /* END FOR idx IN vr_tab_lancto_parcelas.FIRST..vr_tab_lancto_parcelas.LAST LOOP */
      
      -- Vamos verificar se os valores das parcelas ficaram com saldos negativos
      OPEN cr_crappep_saldo(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep_saldo
       INTO vr_flgnegat;
      CLOSE cr_crappep_saldo;                        
      
      IF NVL(vr_flgnegat,0) = 1 THEN
        vr_cdcritic := 968;
        RAISE vr_exc_saida;
      END IF;
   
      -- Busca a data do ultimo pagamento do Emprestimo
      OPEN cr_crappep_max_pagto(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep_max_pagto
       INTO vr_dtultpag;
      CLOSE cr_crappep_max_pagto;
      
      -- Busca a data do primeiro vencimento da parcela nao pago
      OPEN cr_crappep_min_dtvencto(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep_min_dtvencto
       INTO vr_dtvencto;
      CLOSE cr_crappep_min_dtvencto;
      
      -- Atualiza os dados do Emprestimo
      BEGIN
        UPDATE crapepr
           SET crapepr.dtultpag = vr_dtultpag
              ,crapepr.dtdpagto = vr_dtvencto
              ,crapepr.inliquid = 0
              ,crapepr.dtliquid = NULL
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar a tabela crapepr. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      --Percorrer os Lancamentos
      vr_index_lanc := vr_tab_lancto_cc.FIRST;
      WHILE vr_index_lanc IS NOT NULL LOOP
        
        -- Vamos verificar se o historico do lancamento possui historico de estorno cadastrado
        OPEN cr_craphis (pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper,
                         pr_cdhistor => vr_tab_lancto_cc(vr_index_lanc).cdhistor);
        FETCH cr_craphis
         INTO vr_cdhisest;
        CLOSE cr_craphis;
        
        IF NVL(vr_cdhisest,0) = 0 THEN
          vr_dscritic := 'Historico nao possui codigo de estorno cadastrado. Historico: ' || TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).cdhistor);
          RAISE vr_exc_saida;
        END IF;
        
        --> Verificar se conta nao está em prejuizo
        IF NOT PREJ0003.fn_verifica_preju_conta(pr_cdcooper, pr_nrdconta) THEN 
        
        /* Lanca em C/C e atualiza o lote */
        EMPR0001.pc_cria_lancamento_cc (pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper --> Cooperativa conectada
                                       ,pr_dtmvtolt => vr_tab_lancto_cc(vr_index_lanc).dtmvtolt --> Movimento atual
                                       ,pr_cdagenci => vr_tab_lancto_cc(vr_index_lanc).cdagenci --> Código da agência
                                       ,pr_cdbccxlt => vr_tab_lancto_cc(vr_index_lanc).cdbccxlt --> Número do caixa
                                       ,pr_cdoperad => vr_tab_lancto_cc(vr_index_lanc).cdoperad --> Código do Operador
                                       ,pr_cdpactra => vr_tab_lancto_cc(vr_index_lanc).cdpactra --> P.A. da transação
                                       ,pr_nrdolote => vr_tab_lancto_cc(vr_index_lanc).nrdolote --> Numero do Lote
                                       ,pr_nrdconta => vr_tab_lancto_cc(vr_index_lanc).nrdconta --> Número da conta
                                       ,pr_cdhistor => vr_cdhisest                              --> Codigo historico
                                       ,pr_vllanmto => vr_tab_lancto_cc(vr_index_lanc).vllanmto --> Valor da parcela emprestimo
                                       ,pr_nrparepr => 0                                        --> Número parcelas empréstimo
                                       ,pr_nrctremp => vr_tab_lancto_cc(vr_index_lanc).nrctremp --> Número do contrato de empréstimo
                                       ,pr_nrseqava => vr_tab_lancto_cc(vr_index_lanc).nrseqava --> Pagamento: Sequencia do avalista
                                       ,pr_des_reto => vr_des_reto                              --> Retorno OK / NOK
                                       ,pr_tab_erro => vr_tab_erro);                            --> Tabela com possíves erros  
      
        IF vr_des_reto = 'NOK' THEN
          IF vr_tab_erro.COUNT > 0 THEN
            -- Buscar o erro encontrado para gravar na vr_des_erro
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            RAISE vr_exc_saida;
          END IF;
        END IF;
          
   ELSE
          
          --> Caso esteja o credito de estono deve ser direcionado ao bloqueio prejuizo
          PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper, --> Cooperativa conectada
                                      pr_nrdconta =>  vr_tab_lancto_cc(vr_index_lanc).nrdconta, --> Número da conta,
                                      pr_cdoperad =>  vr_tab_lancto_cc(vr_index_lanc).cdoperad, --> Código do Operador,
                                      pr_vlrlanc  => vr_tab_lancto_cc(vr_index_lanc).vllanmto, --> Valor da parcela emprestimo,
                                      pr_dtmvtolt => vr_tab_lancto_cc(vr_index_lanc).dtmvtolt, --> Movimento atual
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);   
         
       IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_saida;
       END IF;
          
   END IF; 
        
        --Proximo registro
        vr_index_lanc := vr_tab_lancto_cc.NEXT(vr_index_lanc);        
       
      END LOOP;     
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Desfaz a Transacao
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Desfaz a Transacao
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_estornar_pagamentos: ' || SQLERRM;
    END;  
             
  END pc_tela_estornar_pagamentos_PP;

  
  PROCEDURE pc_grava_estorno_preju_CC( pr_cdcooper IN tbcc_prejuizo_detalhe.cdcooper%TYPE --> Código da cooperativa
                                      ,pr_nrdconta IN tbcc_prejuizo_detalhe.nrdconta%TYPE --> Conta do cooperado
                                      ,pr_totalest IN tbcc_prejuizo_detalhe.vllanmto%TYPE --> Total a estornar
                                      ,pr_justific IN VARCHAR2                            --> Descrição da justificativa
                                      --> CAMPOS IN/OUT PADRÃO DA MENSAGERIA
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                      )IS            --Saida OK/NOK

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
       AND d.dthrtran >= pr_dtinilan 
       AND d.dthrtran <= pr_dtfinlan
       AND d.cdhistor IN (2733, --> REC. PREJUIZO
                          2723, --> ABONO PREJUIZO
                          2725, --> BX.PREJ.PRIN
                          2727, --> BX.PREJ.JUROS
                          2729) --> BX.PREJ.JUROS        
  ORDER BY d.dtmvtolt DESC, d.dthrtran DESC;
    rw_detalhe_ult_lanc cr_detalhe_ult_lanc%ROWTYPE;

    --> Consultar todos os historicos para soma à estornar
    --> 2723 ¿ Abono de prejuízo
    --> 2725 ¿ Pagamento do valor principal do prejuízo
    --> 2727 ¿ Pagamento dos juros +60 da transferência para prejuízo
    --> 2729 ¿ Pagamento dos juros remuneratórios do prejuízo
    --> 2323 ¿ Pagamento de IOF provisionado
    --> 2721 ¿ Débito para pagamento do prejuízo (para fins contábeis)
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
       AND(d.cdhistor = 2723  --> 2723 ¿ Abono de prejuízo
        OR d.cdhistor = 2725  --> 2725 ¿ Pagamento do valor principal do prejuízo
        OR d.cdhistor = 2727  --> 2727 ¿ Pagamento dos juros +60 da transferência para prejuízo
        OR d.cdhistor = 2729  --> 2729 ¿ Pagamento dos juros remuneratórios do prejuízo
                OR d.cdhistor = 2323  --> 2323 ¿ Pagamento do IOF
        OR d.cdhistor = 2721  --> 2721 ¿ Débito para pagamento do prejuízo (para fins contábeis)
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
    
    
    vr_cdcooper := pr_cdcooper;
    vr_nmdatela := 'ATENDA';
    vr_cdagenci := 1;
    vr_nrdcaixa := 1;
    vr_idorigem := 7;
    vr_cdoperad := 1; 
    
        
    OPEN BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

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
                                       , pr_hrtransa => gene0002.fn_busca_time
                                       , pr_nrseqdig => vr_nrseqdig
                                       , pr_vllanmto => vr_valordeb
                                       , pr_nrdctabb => pr_nrdconta
                                       , pr_cdpesqbb => 'ESTORNO DE PAGAMENTO DE PREJUÍZO DE C/C'
                                       , pr_dtrefere => rw_crapdat.dtmvtolt
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
                                       , pr_hrtransa => gene0002.fn_busca_time
                                       , pr_nrseqdig => vr_nrseqdig
                                       , pr_vllanmto => vr_vldpagto
                                       , pr_nrdctabb => pr_nrdconta
                                       , pr_cdpesqbb => 'ESTORNO DE ABONO DE PREJUÍZO DE C/C'
                                       , pr_dtrefere => rw_crapdat.dtmvtolt
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


    pr_cdcritic := NULL;
    pr_dscritic := NULL;

  EXCEPTION
    WHEN vr_exc_erro THEN      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
     
    WHEN OTHERS THEN
      
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_grava_estorno_preju --> '|| SQLERRM;

  END pc_grava_estorno_preju_cc;


  
  PROCEDURE pc_realiza_estor_tit_prj(pr_cdcooper        IN crapbdt.cdcooper%TYPE
                                    ,pr_nrborder        IN craptdb.nrborder%TYPE
                                    ,pr_nrtitulo        IN craptdb.nrtitulo%TYPE
                                    ,pr_vlsdprej        IN craptdb.vlsdprej%TYPE DEFAULT 0
                                    ,pr_vlpgjmpr        IN craptdb.vlpgjmpr%TYPE DEFAULT 0
                                    ,pr_vlpgmupr        IN craptdb.vlpgmupr%TYPE DEFAULT 0
                                    ,pr_vlpgjrpr        IN craptdb.vlpgjrpr%TYPE DEFAULT 0
                                    ,pr_cdcritic        OUT PLS_INTEGER          --> Codigo da Critica
                                    ,pr_dscritic        OUT VARCHAR2) IS
   /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_realiza_estor_tit_prj
      Sistema  : 
      Sigla    : CRED
      Autor    : Vitor S. Assanuma
      Data     : 08/11/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Atualiza a situação do titulo em prejuizo
    ---------------------------------------------------------------------------------------------------------------------*/
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
    vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
      
    BEGIN
      UPDATE craptdb tdb
         SET tdb.insittit = 4
            ,tdb.dtdebito = NULL
            ,tdb.vlsdprej = tdb.vlsdprej + NVL(pr_vlsdprej, 0) -- Saldo Prejuizo
            ,tdb.vlpgjmpr = tdb.vlpgjmpr - NVL(pr_vlpgjmpr, 0) -- Juros Mora
            ,tdb.vlpgmupr = tdb.vlpgmupr - NVL(pr_vlpgmupr, 0) -- Multa
            ,tdb.vlpgjrpr = tdb.vlpgjrpr - NVL(pr_vlpgjrpr, 0) -- Acumulado
            ,tdb.vlpgjm60 = CASE WHEN (NVL(pr_vlpgjmpr,0) >= tdb.vlpgjm60) THEN 0 ELSE (tdb.vlpgjm60 - NVL(pr_vlpgjmpr,0)) END
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.nrborder = pr_nrborder
         AND tdb.nrtitulo = pr_nrtitulo;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Não foi possivel atualizar a situção dos títulos.';
  END pc_realiza_estor_tit_prj;
  
  PROCEDURE pc_realiza_estorno_prejuizo_tit ( pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                             ,pr_nrdconta  IN crapbdt.nrdconta%TYPE
                                             ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                             ,pr_cdagenci  IN crapbdt.cdagenci%TYPE
                                             ,pr_cdoperad  IN crapbdt.cdoperad%TYPE
                                             ,pr_dsjustificativa IN VARCHAR2
                                             -- OUT --
                                             ,pr_cdcritic OUT PLS_INTEGER
                                             ,pr_dscritic OUT VARCHAR2
                                             ) IS
   /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_realiza_estorno_prejuizo
      Sistema  : 
      Sigla    : CRED
      Autor    : Vitor S. Assanuma (GFT)
      Data     : 08/11/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Realizar o Estorno do Borderô em Prejuízo
      Alterações:
      -- Lucas Negoseki (GFT) - Adicionado novo histórico 2876 na busca de lançamentos borderô
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erro
    vr_exc_erro EXCEPTION;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
    vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
      
    -- Variável de Data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variáveis locais
    vr_cdestorno       NUMBER;
    vr_est_abono       NUMBER(25,2);
    vr_cdhistor        NUMBER;
    vr_vllanmto_tot    NUMBER(25,2);
    vr_nrdolote craplcm.nrdolote%TYPE;
    vr_nrseqdig craplcm.nrseqdig%TYPE;    
    
    -- Cursor para verificar se há algum titulo do bordero em acordo
    CURSOR cr_crapaco IS
      SELECT
        COUNT(1) AS in_acordo
      FROM
        tbdsct_titulo_cyber ttc
      INNER JOIN tbrecup_acordo ta ON ta.cdcooper = ttc.cdcooper AND ta.nrdconta = ttc.nrdconta
      INNER JOIN tbrecup_acordo_contrato tac ON ttc.nrctrdsc = tac.nrctremp AND tac.nracordo = ta.nracordo
      WHERE ttc.cdcooper = pr_cdcooper
        AND ttc.nrdconta = pr_nrdconta
        AND ttc.nrborder = pr_nrborder
        AND tac.cdorigem = 4   -- Desconto de Títulos
        AND ta.cdsituacao <> 3; -- Diferente de Cancelado
    rw_crapaco cr_crapaco%ROWTYPE;
    
    -- Cursor de lançamentos
    CURSOR cr_craplan(pr_dtini DATE,
                      pr_dtfim DATE) IS
      SELECT 
        tlb.cdcooper,
        tlb.nrdconta,
        tlb.nrborder,
        tlb.cdbandoc, 
        tlb.nrdctabb, 
        tlb.nrcnvcob, 
        tlb.nrdocmto, 
        tlb.nrtitulo,
        tlb.dtmvtolt,
        tlb.vllanmto,
        tlb.cdhistor,
        tlb.cdorigem,
        tlb.progress_recid AS id
      FROM tbdsct_lancamento_bordero tlb
      WHERE tlb.cdcooper = pr_cdcooper 
        AND tlb.nrborder = pr_nrborder 
        AND tlb.cdorigem IN (5, 7) 
        AND tlb.dthrtran >= pr_dtinilan
        AND tlb.dthrtran <= pr_dtfinlan
        AND tlb.dtmvtolt BETWEEN  pr_dtini AND pr_dtfim
         AND tlb.dtmvtolt >= (SELECT MAX(lan.dtmvtolt) 
                              FROM tbdsct_lancamento_bordero lan
                              INNER JOIN craphis his ON lan.cdcooper = his.cdcooper AND lan.cdhistor = his.cdhistor AND his.indebcre = 'C'
                              WHERE lan.cdcooper = pr_cdcooper 
                                AND lan.nrdconta = pr_nrdconta 
                                AND lan.nrborder = pr_nrborder 
                                AND lan.cdorigem IN (5, 7)
                                AND tlb.cdhistor IN (PREJ0005.vr_cdhistordsct_rec_abono      -- ABONO PREJUIZO        [2689]
                                                    ,PREJ0005.vr_cdhistordsct_rec_principal  -- PAG.PREJUIZO PRINCIP. [2770]
                                                    ,PREJ0005.vr_cdhistordsct_rec_jur_60     -- PGTO JUROS +60        [2771]
                                                    ,PREJ0005.vr_cdhistordsct_rec_jur_atuali -- PAGTO JUROS  PREJUIZO [2772]
                                                    ,PREJ0005.vr_cdhistordsct_rec_mult_atras -- PGTO MULTA ATRASO     [2773]
                                                    ,PREJ0005.vr_cdhistordsct_rec_jur_mora   -- PGTO JUROS MORA       [2774]
                                                    ,DSCT0003.vr_cdhistordsct_sumjratuprejuz -- SOMATORIO DOS JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO [2798]
                                                    ,PREJ0005.vr_cdhistordsct_rec_preju      -- PAGTO RECUPERAÇÃO PREJUIZO                                        
                                                    )
                              )
        AND tlb.dtmvtolt >= NVL((SELECT MAX(dtestorno) FROM tbdsct_estorno WHERE cdcooper = pr_cdcooper AND nrdconta = pr_nrdconta AND nrborder = pr_nrborder),pr_dtini)
        AND tlb.cdhistor IN (PREJ0005.vr_cdhistordsct_rec_abono      -- ABONO PREJUIZO        [2689]
                            ,PREJ0005.vr_cdhistordsct_rec_principal  -- PAG.PREJUIZO PRINCIP. [2770]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_60     -- PGTO JUROS +60        [2771]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_atuali -- PAGTO JUROS  PREJUIZO [2772]
                            ,PREJ0005.vr_cdhistordsct_rec_mult_atras -- PGTO MULTA ATRASO     [2773]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_mora   -- PGTO JUROS MORA       [2774]
                            ,DSCT0003.vr_cdhistordsct_sumjratuprejuz -- SOMATORIO DOS JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO [2798]
                            ,PREJ0005.vr_cdhistordsct_rec_preju      -- PAGTO RECUPERAÇÃO PREJUIZO                                        
                            )
        AND tlb.dtestorn IS NULL
      ORDER BY tlb.nrtitulo;
    rw_craplan cr_craplan%ROWTYPE;
    
    -- Cursor de lançamento do estorno
    CURSOR cr_craplcm IS
      SELECT lcm.dtmvtolt,
          NVL(SUM(lcm.vllanmto), 0) AS vllanmto,
          lcm.cdhistor,
          lcm.cdbccxlt,
          lcm.nrdocmto
      FROM craplcm lcm
      WHERE lcm.cdcooper = pr_cdcooper
        AND lcm.nrdconta = pr_nrdconta
        AND lcm.nrdocmto = pr_nrborder
        AND lcm.cdhistor = PREJ0005.vr_cdhistordsct_recup_preju
      GROUP BY lcm.dtmvtolt, lcm.cdhistor, lcm.cdbccxlt, lcm.nrdocmto
      ORDER BY lcm.dtmvtolt DESC;
    rw_craplcm cr_craplcm%ROWTYPE;
    
    -- Cursor para saber se houve algum estorno no dia
    CURSOR cr_crapestorno(pr_cdcooper crapbdt.cdcooper%TYPE
                         ,pr_nrdconta crapbdt.nrdconta%TYPE
                         ,pr_nrborder crapbdt.nrborder%TYPE
                         ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT NVL(SUM(vllancamento),0) vllancamento
      FROM
        tbdsct_estornolancamento tbe
      WHERE tbe.cdcooper    = pr_cdcooper
        AND tbe.nrdconta    = pr_nrdconta
        AND tbe.nrborder    = pr_nrborder
        AND tbe.dtpagamento = pr_dtmvtolt;
    rw_crapestorno cr_crapestorno%ROWTYPE;
    
    BEGIN
      
      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;
      
      vr_est_abono       := 0;
      -- Abre o cursor de lançamentos para efetuar os de estorno.
      OPEN cr_craplan(pr_dtini => rw_crapdat.dtinimes,
                      pr_dtfim => rw_crapdat.dtultdia);
      LOOP
        FETCH cr_craplan INTO rw_craplan;
        EXIT WHEN cr_craplan%NOTFOUND;
        
        -- Verifica qual o histórico de estorno deve ser lançado
        CASE rw_craplan.cdhistor            
          -- Abono
          WHEN PREJ0005.vr_cdhistordsct_rec_abono      THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_abono;
            vr_est_abono := vr_est_abono + rw_craplan.vllanmto;
                      
          -- Principal
          WHEN PREJ0005.vr_cdhistordsct_rec_principal  THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_principal;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlsdprej => rw_craplan.vllanmto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Principal retira do saldo
          -- Juros +60
          WHEN PREJ0005.vr_cdhistordsct_rec_jur_60     THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_jur_60;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlsdprej => rw_craplan.vllanmto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Juros+60 retira do saldo
          -- Atualização
          WHEN PREJ0005.vr_cdhistordsct_rec_jur_atuali THEN 
            vr_cdhistor        := PREJ0005.vr_cdhistordsct_est_jur_prej;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlpgjrpr => rw_craplan.vllanmto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Juros de Atualização
          -- Multa
          WHEN PREJ0005.vr_cdhistordsct_rec_mult_atras THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_mult_atras;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlpgmupr => rw_craplan.vllanmto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Multa
          -- Mora
          WHEN PREJ0005.vr_cdhistordsct_rec_jur_mora   THEN 
            vr_cdhistor := PREJ0005.vr_cdhistordsct_est_jur_mor;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlpgjmpr => rw_craplan.vllanmto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Mora
          -- Juros de atualização
          WHEN DSCT0003.vr_cdhistordsct_sumjratuprejuz THEN
            vr_cdhistor := DSCT0003.vr_cdhistordsct_sumjratuprejuz;
            
          WHEN PREJ0005.vr_cdhistordsct_rec_preju THEN
            vr_cdhistor := PREJ0005.vr_cdhistordsct_est_preju;
        END CASE;
        
        -- Verifica se houve crítica   
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Caso o lançamento seja o mesmo dia de movimento deleta os lançamentos.
        IF (rw_craplan.dtmvtolt = rw_crapdat.dtmvtolt) THEN
          BEGIN
            DELETE FROM tbdsct_lancamento_bordero WHERE progress_recid = rw_craplan.id;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel remover o lançamento dos Lançamentos de Borderô.';
              RAISE vr_exc_erro;
          END; 
        ELSIF vr_cdhistor <> DSCT0003.vr_cdhistordsct_sumjratuprejuz THEN -- lançamento de juros de atualização
          -- Inserir registros de lancamento de estorno do borderô na tabela tbdsct_lancamento_border
          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper, 
                                                 pr_nrdconta => pr_nrdconta, 
                                                 pr_nrborder => pr_nrborder, 
                                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                 pr_cdorigem => rw_craplan.cdorigem, 
                                                 pr_cdhistor => vr_cdhistor, 
                                                 pr_vllanmto => rw_craplan.vllanmto, 
                                                 pr_cdbandoc => rw_craplan.cdbandoc, 
                                                 pr_nrdctabb => rw_craplan.nrdctabb, 
                                                 pr_nrcnvcob => rw_craplan.nrcnvcob, 
                                                 pr_nrdocmto => rw_craplan.nrdocmto, 
                                                 pr_nrtitulo => rw_craplan.nrtitulo, 
                                                 pr_dscritic => pr_dscritic);
          -- Verifica se houve crítica   
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Atualiza o campo de estorno
          BEGIN
            UPDATE tbdsct_lancamento_bordero SET dtestorn = rw_crapdat.dtmvtolt WHERE progress_recid = rw_craplan.id;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel atualizar a data de estorno dos Lançamentos de Borderô.';
              RAISE vr_exc_erro;
          END; 
        END IF;
      END LOOP;
      CLOSE cr_craplan; 
        
      -- Atualiza o Borderô 
      BEGIN
        UPDATE crapbdt bdt
        SET bdt.insitbdt = 3,
            bdt.dtliqprj = NULL,
            bdt.vlaboprj = bdt.vlaboprj - vr_est_abono
        WHERE bdt.cdcooper = pr_cdcooper 
          AND bdt.nrborder = pr_nrborder;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel atualizar a situação do Borderô.';
          RAISE vr_exc_erro;
      END;
      
      vr_vllanmto_tot := 0;
      -- Faz o estorno do último lançamento da LCM
      OPEN  cr_craplcm;
      FETCH cr_craplcm INTO rw_craplcm;
      CLOSE cr_craplcm;
      
      --Cria o registro do Estorno
      DSCT0005.pc_insere_estorno(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrborder => pr_nrborder
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_cdagenci => pr_cdagenci
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_justific => pr_dsjustificativa
                       -- OUT --
                       ,pr_cdestorno => vr_cdestorno
                       ,pr_cdcritic  => vr_cdcritic
                       ,pr_dscritic  => vr_dscritic
                       );
                       
      IF TRIM(vr_dscritic) IS NOT NULL THEN
         vr_cdcritic := 0;
         RAISE vr_exc_erro;
      END IF;
      
      OPEN cr_crapestorno(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         );
      FETCH cr_crapestorno INTO rw_crapestorno;
      CLOSE cr_crapestorno;
      
      -- Caso tenha lançamentos no dia, retirar o que já foi lançado.
      vr_vllanmto_tot := rw_craplcm.vllanmto - rw_crapestorno.vllancamento;
      
      -- Insere o estorno na tabela de lançamentos de estorno
      DSCT0005.pc_insere_estornolancamento(pr_cdcooper    => pr_cdcooper
                                 ,pr_nrdconta    => pr_nrdconta
                                 ,pr_nrborder    => pr_nrborder
                                 ,pr_nrtitulo    => 0           -- É do borderô
                                 ,pr_dtvencto    => NULL        -- É do borderô
                                 ,pr_dtpagamento => rw_craplcm.dtmvtolt
                                 ,pr_vllanmto    => vr_vllanmto_tot
                                 ,pr_cdestorno   => vr_cdestorno
                                 ,pr_cdhistor    => rw_craplcm.cdhistor
                                 ,pr_cdcritic    => pr_cdcritic
                                 ,pr_dscritic    => pr_dscritic);
                                       
      IF TRIM(pr_dscritic) IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := pr_dscritic;
        RAISE vr_exc_erro;      
      END IF;
      
      -- Caso tenha abono faz mais um lançamento dentro do estorno_lancamento
      IF vr_est_abono > 0 THEN
        -- Insere o estorno na tabela de lançamentos de estorno
        DSCT0005.pc_insere_estornolancamento(pr_cdcooper    => pr_cdcooper
                                   ,pr_nrdconta    => pr_nrdconta
                                   ,pr_nrborder    => pr_nrborder
                                   ,pr_nrtitulo    => 0           -- É do borderô
                                   ,pr_dtvencto    => NULL        -- É do borderô
                                   ,pr_dtpagamento => rw_craplcm.dtmvtolt
                                   ,pr_vllanmto    => vr_est_abono
                                   ,pr_cdestorno   => vr_cdestorno
                                   ,pr_cdhistor    => PREJ0005.vr_cdhistordsct_rec_abono
                                   ,pr_cdcritic    => pr_cdcritic
                                   ,pr_dscritic    => pr_dscritic);
                                         
        IF TRIM(pr_dscritic) IS NOT NULL THEN
          vr_cdcritic := 0;
          vr_dscritic := pr_dscritic;
          RAISE vr_exc_erro;      
        END IF;
      END IF;
      
      -- Caso o lançamento seja do mesmo dia deleta os lançamentos, senão lança na CC o estorno.
      IF (rw_craplcm.dtmvtolt = rw_crapdat.dtmvtolt) THEN
        BEGIN
          DELETE FROM craplcm lcm WHERE lcm.cdcooper = pr_cdcooper 
                                    AND lcm.nrdconta = pr_nrdconta
                                    AND lcm.nrdocmto = pr_nrborder 
                                    AND lcm.dtmvtolt  = rw_craplcm.dtmvtolt
                                    AND lcm.cdhistor = PREJ0005.vr_cdhistordsct_recup_preju;
        EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel remover os registros na craplcm.';
          RAISE vr_exc_erro;
        END; 
      ELSE
        -- Realizar Lançamento do estorno na craplcm de Desconto de Títulos
        DSCT0003.pc_efetua_lanc_cc(pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_cdagenci => pr_cdagenci, 
                                   pr_cdbccxlt => rw_craplcm.cdbccxlt, 
                                   pr_nrdconta => pr_nrdconta, 
                                   pr_vllanmto => vr_vllanmto_tot,
                                   pr_cdhistor => PREJ0005.vr_cdhistordsct_est_rec_princi, 
                                   pr_cdcooper => pr_cdcooper, 
                                   pr_cdoperad => pr_cdoperad, 
                                   pr_nrborder => pr_nrborder, 
                                   pr_cdpactra => NULL, 
                                   pr_nrdocmto => rw_craplcm.nrdocmto, 
                                   pr_nrdolote => vr_nrdolote,
                                   pr_nrseqdig => vr_nrseqdig,                                   
                                   pr_cdcritic => pr_cdcritic, 
                                   pr_dscritic => pr_dscritic);
                                   
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN 
        IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina DSCT0005.pc_realiza_estorno_prejuizo: ' || SQLERRM;
    
  END pc_realiza_estorno_prejuizo_tit;





BEGIN

  dbms_output.put_line(to_char(pr_dtinilan,'DD/MM/RRRR hh24:mi'));

  -- Leitura do calendário da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => 1);
  FETCH btch0001.cr_crapdat into rw_crapdat;
  IF (btch0001.cr_crapdat%NOTFOUND) THEN
    CLOSE btch0001.cr_crapdat;
    vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
    RAISE vr_exc_erro;
  END IF;
  CLOSE btch0001.cr_crapdat;
  
  vr_dsdiret := gene0001.fn_diretorio(pr_tpdireto => 'M',
                                      pr_cdcooper => '0',
                                      pr_nmsubdir => '/cpd/bacas/');


  --Abrir o arquivo lido
  gene0001.pc_abre_arquivo( pr_nmdireto => vr_dsdiret||'/'||vr_dsINC   --> Diretório do arquivo
                           ,pr_nmarquiv => 'LISTAACORDOS.txt'          --> Nome do arquivo
                           ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                           ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                           ,pr_des_erro => vr_des_erro);  --> Erro

  IF vr_des_erro <> 'OK' THEN
    vr_dscritic := 'Erro ao abrir arquivo: '||vr_des_erro; 
    RAISE vr_exc_erro;  
  END IF;  
  
  vr_nrlinha := 0;
  LOOP
    --Verificar se o arquivo está aberto
    BEGIN
     -- Le os dados do arquivo e coloca na variavel vr_setlinha
     gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                 ,pr_des_text => vr_setlinha); --> Texto lido

     vr_nrlinha := vr_nrlinha + 1;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       -- Fechar o arquivo
       GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
       --Fim do arquivo
       EXIT;
    END;
    
    vr_nracordo := REPLACE(REPLACE(vr_setlinha,chr(13)),chr(10));
    pc_gera_log(pr_nracordo => vr_nracordo ,
                pr_cdorigem => NULL ,
                pr_nrctremp => NULL,
                pr_log      => 'Linha '||vr_nrlinha||';'||'Acordo:'||vr_nracordo);
    
    BEGIN
      FOR rw_tbrecup_acordo IN cr_tbrecup_acordo(pr_nracordo => vr_nracordo) LOOP
        
        vr_totalest := 0;
        
        pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                    pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                    pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                    pr_log      => 'INICIO Estorno');

        IF rw_tbrecup_acordo.cdorigem IN (2,3) THEN

          rw_crapepr_aco := NULL;
          OPEN cr_crapepr_aco(pr_cdcooper => rw_tbrecup_acordo.cdcooper
                             ,pr_nrdconta => rw_tbrecup_acordo.nrdconta
                             ,pr_nrctremp => rw_tbrecup_acordo.nrctremp);
          FETCH cr_crapepr_aco INTO rw_crapepr_aco;
          CLOSE cr_crapepr_aco;

          IF rw_crapepr_aco.inprejuz = 1 THEN
            --> Emprestimo Prejuizo  - PREJ0002
            pc_estorno_pagamento_epr_prej (pr_cdcooper => rw_tbrecup_acordo.cdcooper
                                 ,pr_cdagenci => 1
                                 ,pr_nrdconta => rw_tbrecup_acordo.nrdconta
                                 ,pr_nrctremp => rw_tbrecup_acordo.nrctremp
                                 ,pr_dtmvtolt => pr_dtestorn
                                 ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                 ,pr_tab_erro => vr_tab_erro);
            IF vr_des_reto = 'NOK' THEN
              IF vr_tab_erro.exists(vr_tab_erro.first) THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Não foi possivel executar estorno do Pagamento do Prejuízo.';
              END IF;
              RAISE vr_exc_erro;
            END IF;
            
            pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                        pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                        pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                        pr_log      => 'Epr Prejuizo Estornado');
                    
          ELSIF rw_crapepr_aco.tpemprst = 2 THEN
            pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                        pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                        pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                        pr_log      => 'Nao eh possivel estornar EPR POS');
          ELSIF rw_crapepr_aco.tpemprst = 0 THEN
            pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                        pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                        pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                        pr_log      => 'Nao eh possivel estornar EPR TR');              
          ELSIF rw_crapepr_aco.tpemprst = 1 THEN
             pc_tela_estornar_pagamentos_PP(pr_cdcooper => rw_tbrecup_acordo.cdcooper      --> Cooperativa conectada
                                           ,pr_cdagenci => 1  --> Código da agência
                                           ,pr_nrdcaixa => 1  --> Número do caixa
                                           ,pr_cdoperad => 1  --> Código do Operador
                                           ,pr_nmdatela => 'ATENDA'  --> Nome da tela
                                           ,pr_idorigem => 7  --> Id do módulo de sistema
                                           ,pr_nrdconta => rw_tbrecup_acordo.nrdconta  --> Número da conta
                                           ,pr_idseqttl => 1  --> Seq titula
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Movimento atual
                                           ,pr_dtmvtopr => rw_crapdat.dtmvtopr  --> Movimento atual
                                           ,pr_nrctremp => rw_tbrecup_acordo.nrctremp  --> Número do contrato de empréstimo
                                           ,pr_dsjustificativa => 'Estorno acordo '||rw_tbrecup_acordo.nracordo ||', INC - pagamento em duplicidade'
                                           ,pr_cdcritic => vr_cdcritic         --> Codigo da Critica
                                           ,pr_dscritic => vr_dscritic);         --> Erros do processo
                                           
            IF upper(vr_dscritic) = upper('A data do ultimo pagamento deve estar dentro do mes') THEN
              vr_dscritic := NULL;
              pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                          pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                          pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                          pr_log      => 'Epr PP NAO Estornado');
              CONTINUE;
            ELSIF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            
            pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                        pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                        pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                        pr_log      => 'Epr PP Estornado');
            
          END IF;

        ELSIF rw_tbrecup_acordo.cdorigem = 1 THEN
          
          rw_crapass_aco := NULL;
          OPEN cr_crapass_aco(pr_cdcooper => rw_tbrecup_acordo.cdcooper,
                              pr_nrdconta => rw_tbrecup_acordo.nrdconta);
          FETCH cr_crapass_aco INTO rw_crapass_aco;
          CLOSE cr_crapass_aco;
          
          IF rw_crapass_aco.inprejuz = 1 THEN
            pc_grava_estorno_preju_CC( pr_cdcooper => rw_tbrecup_acordo.cdcooper --> Código da cooperativa
                                      ,pr_nrdconta => rw_tbrecup_acordo.nrdconta --> Conta do cooperado
                                      ,pr_totalest => vr_totalest                --> Total a estornar
                                      ,pr_justific => 'Estorno acordo '||rw_tbrecup_acordo.nracordo ||', INC - pagamento em duplicidade'
                                      ,pr_cdcritic => vr_cdcritic    --> Codigo da Critica
                                      ,pr_dscritic => vr_dscritic);  --> Erros do processo
                                      
            IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            
            pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                        pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                        pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                        pr_log      => 'CC Prej Estornada');
          ELSE 
            pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                        pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                        pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                        pr_log      => 'CC Prej Nao possui estorno');
          END IF;
          
        ELSIF rw_tbrecup_acordo.cdorigem = 4 THEN
          
          FOR rw_crapbdt IN cr_crapbdt(pr_nracordo => rw_tbrecup_acordo.nracordo) LOOP
            
            pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                        pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                        pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                        pr_log      => 'Estorno Bordero '||rw_crapbdt.nrborder);
            IF vr_tab_bordero_estornado.exists(lpad(rw_tbrecup_acordo.nracordo,10,0)||
                                               lpad(rw_crapbdt.nrborder,10,0)) THEN
              pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                          pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                          pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                          pr_log      => 'Estorno Bordero '||rw_crapbdt.nrborder ||' ja realizado');                                 
              CONTINUE;  
            END IF;  
            
            IF rw_crapbdt.inprejuz = 1 THEN  
              pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                        pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                        pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                        pr_log      => 'Tit prej, estorno nao tratado');
                        /* 
              pc_realiza_estorno_prejuizo_tit(pr_cdcooper  => rw_tbrecup_acordo.cdcooper
                                             ,pr_nrdconta  => rw_tbrecup_acordo.nrdconta
                                             ,pr_nrborder  => rw_crapbdt.nrborder
                                             ,pr_cdagenci  => 1
                                             ,pr_cdoperad  => 1
                                             ,pr_dsjustificativa => 'Estorno acordo '||rw_tbrecup_acordo.nracordo ||', INC - pagamento em duplicidade'
                                             -- OUT --
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

              IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;  
              
              pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                        pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                        pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                        pr_log      => 'Bordero Prej Estornado');
              
              vr_tab_bordero_estornado(lpad(rw_tbrecup_acordo.nracordo,10,0)||
                                       lpad(rw_crapbdt.nrborder,10,0)) := rw_crapbdt.nrborder; 
                                       */
            ELSE
              pc_gera_log(pr_nracordo => rw_tbrecup_acordo.nracordo ,
                        pr_cdorigem => rw_tbrecup_acordo.cdorigem ,
                        pr_nrctremp => rw_tbrecup_acordo.nrctremp ,
                        pr_log      => 'Tit ativo, estorno nao tratado');
            END IF;  
          END LOOP;  
        END IF;
 
      END LOOP;
      
      --> Salvar a cada acordo
      COMMIT;
      
    EXCEPTION 
      WHEN vr_exc_erro THEN
        pc_gera_log(pr_nracordo => vr_nracordo ,
                    pr_cdorigem => NULL ,
                    pr_nrctremp => NULL ,
                    pr_log      => 'Erro ao estornar: '||vr_cdcritic||'-'||vr_dscritic);
        ROLLBACK;
      WHEN OTHERS THEN
        
        pc_gera_log(pr_nracordo => vr_nracordo ,
                    pr_cdorigem => NULL ,
                    pr_nrctremp => NULL ,
                    pr_log      => 'Erro ao estornar: '||SQLERRM); 
        ROLLBACK;            
        
    END;
  END LOOP;  

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500,vr_cdcritic||'-'||vr_dscritic);

END;

