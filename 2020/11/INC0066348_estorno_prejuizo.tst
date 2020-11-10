PL/SQL Developer Test script 3.0
640
  /* Rotina para estornar pagamento parcial 
  PROCEDURE pc_estorno_pagamento() IS
  .............................................................................
  Programa: pc_estorno_pagamento    
  ..............................................................................*/
  
DECLARE

    pr_cdcooper number := 13;
    pr_cdagenci number := 1;
    pr_nrdconta number := 140082;
    pr_nrctremp number := 20381;
    pr_dtmvtolt DATE := TO_DATE('30/10/2020'); -- Data do pagamento do prejuízo
    pr_des_reto VARCHAR(1000);
    pr_tab_erro gene0001.typ_tab_erro;

    gl_nrdolote             NUMBER;
    vr_des_reto             VARCHAR2(10);
    vr_tab_erro             gene0001.typ_tab_erro ;

      TYPE typ_reg_historico IS RECORD (cdhistor craphis.cdhistor%TYPE
                                      , dscritic VARCHAR2(100));
                                      
      TYPE typ_tab_historicos IS TABLE OF typ_reg_historico INDEX BY PLS_INTEGER;
      
      vr_tab_historicos typ_tab_historicos;
      
      CURSOR cr_crapepr(pr_cdcooper in number
                  ,pr_nrdconta in number
                  ,pr_nrctremp in number) IS
      SELECT *
        FROM crapepr
      WHERE crapepr.cdcooper = pr_cdcooper
        AND crapepr.nrdconta = pr_nrdconta
        AND crapepr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;

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
                lem.nrdolote
           from craplem lem
          where lem.cdcooper = prc_cdcooper
            and lem.nrdconta = prc_nrdconta
            and lem.nrctremp = prc_nrctremp
            and lem.dtmvtolt = prc_dtmvtolt -- ESTORNAR TUDO DO DIA
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
    vr_dsctajud    crapprm.dsvlrprm%TYPE;         --> Parametro de contas que nao podem debitar os emprestimos
    vr_dsctactrjud crapprm.dsvlrprm%TYPE := null; --> Parametro de contas e contratos específicos que nao podem debitar os emprestimos SD#618307
    
    vr_vllanmto craplcm.vllanmto%TYPE;

    EXC_LCT_NAO_EXISTE exception;
    
  
  --
  BEGIN
  
    -- Monta tabela de históricos de pagamento e respectivo histórico de estorno
    -- Reginaldo/AMcom - P450 - 07/12/2018
    vr_tab_historicos(2388).cdhistor := 2392;
    vr_tab_historicos(2388).dscritic := 'valor principal';
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

    -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
    vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');

     -- Lista de contas e contratos específicos que nao podem debitar os emprestimos (formato="(cta,ctr)") SD#618307
    vr_dsctactrjud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_cdacesso => 'CTA_CTR_ACAO_JUDICIAL');

    -- Condicao para verificar se permite incluir as linhas parametrizadas
    IF INSTR(',' || vr_dsctajud || ',',',' || pr_nrdconta || ',') > 0 THEN
      vr_dscritic := 'Atenção! Estorno não permitido. Verifique situação da conta.';
      RAISE vr_erro;
    END IF;

    -- Condicao para verificar se permite incluir as linhas parametrizadas SD#618307
    IF INSTR(replace(vr_dsctactrjud,' '),'('||trim(to_char(pr_nrdconta))||','||trim(to_char(pr_nrctremp))||')') > 0 THEN
      vr_dscritic := 'Atenção! Estorno não permitido. Verifique situação da conta.';
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
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      raise vr_erro;
    END IF;

    IF vr_flgativo = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Estorno nao permitido, emprestimo em acordo';
      pr_des_reto := 'NOK';
      RAISE vr_erro;
    END IF;

    -- Buscar todos os lançamentos efetuados
    FOR r_craplem in c_craplem(prc_cdcooper => pr_cdcooper
                              ,prc_nrdconta => pr_nrdconta
                              ,prc_nrctremp => pr_nrctremp
                              ,prc_dtmvtolt => pr_dtmvtolt) LOOP
                
    IF r_craplem.cdhistor in (2701, 2388) THEN -- Valor Principal             
    r_craplem.vllanmto := 931.72;
    END IF;
                
      -- Estorno na data corrente
      IF r_craplem.dtmvtolt = rw_crapdat.dtmvtolt THEN
        IF r_craplem.cdhistor = 2388 THEN -- Valor Principal
          -- Atualizar o valor vlsdprej da CRAPEPR
          rw_crapepr.vlsdprej := rw_crapepr.vlsdprej + r_craplem.vllanmto;
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
                                             ,pr_nrparepr => r_craplem.nrdocmto
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
        
    -- Confirma alterações
    COMMIT;
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
        -- Commit do LOG
        COMMIT;
  END pc_estorno_pagamento;
0
0
