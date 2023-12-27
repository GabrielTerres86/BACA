DECLARE
  vr_des_reto VARCHAR2 (1000) := NULL;
  vr_tab_reto gene0001.typ_tab_erro;
  vr_descritc VARCHAR2(4000) := NULL;
  gl_nrdolote NUMBER;
  vr_vllanmtosai_princ NUMBER;
  vr_cdcritica NUMBER;
  vr_dscritica VARCHAR2(4000);
  vr_idvlrmin  NUMBER;
  vr_vltotpag  NUMBER;
  
 CURSOR cr_acordo(pr_cdcooper in number
                 ,pr_nrdconta in number
                 ,pr_nrctremp in number) IS
  SELECT a.NRACORDO,
         MAX(p.nrparcela) nrparcela
  FROM  tbrecup_acordo a
       ,tbrecup_acordo_contrato c
       ,tbrecup_acordo_parcela p
  WHERE a.cdcooper = pr_cdcooper
     AND a.nrdconta = pr_nrdconta
     AND c.nrctremp =  pr_nrctremp
     AND c.cdorigem = 3
     AND a.cdsituacao = 1
     AND c.nracordo = a.nracordo 
     AND p.nracordo = c.nracordo
     AND p.vlpago > 0  
     GROUP BY a.NRACORDO;
 rw_acordo cr_acordo%ROWTYPE;     
  
  CURSOR cr_crapepr_est(pr_cdcooper in number
                       ,pr_nrdconta in number
                       ,pr_nrctremp in number) IS
    SELECT *
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
  rw_crapepr_est cr_crapepr_est%ROWTYPE;
  
  CURSOR cr_crapepr IS                   
    SELECT x.cdcooper
          ,x.nrdconta
          ,x.nrctremp
          ,x.tpemprst
     FROM (
       SELECT MIN(p.dtvencimento) dtproximo_vencto
             ,CASE
                 WHEN to_date('19/12/2023', 'DD/MM/RRRR') > MIN(p.dtvencimento) THEN
                   to_date('19/12/2023', 'DD/MM/RRRR') - MIN(p.dtvencimento)
                 ELSE
                   0
                 END qtd_atraso_calc
             ,a.cdcooper
             ,a.nrdconta
             ,b.nrctremp
             ,p.nracordo
             ,b.cdorigem
             ,e.tpemprst
             ,e.progress_recid
         FROM tbrecup_acordo_parcela  p
             ,tbrecup_acordo          a
             ,tbrecup_acordo_contrato b
             ,crapepr                 e
       WHERE a.nracordo   = b.nracordo
         AND a.nracordo   = p.nracordo
         AND a.cdcooper   = e.cdcooper
         AND a.nrdconta   = e.nrdconta
         AND b.nrctremp   = e.nrctremp
         AND a.cdsituacao = 1
         AND p.vlpago     = 0
         AND e.inprejuz   = 1
         AND e.dtprejuz   = to_date('19/12/2023', 'DD/MM/RRRR')
         AND TRUNC(a.DHACORDO) < to_date('19/12/2023', 'DD/MM/RRRR')
    GROUP BY a.cdcooper
            ,a.nrdconta
            ,b.nrctremp
            ,p.nracordo
            ,b.cdorigem
            ,e.tpemprst
            ,e.progress_recid ) x
    WHERE x.qtd_atraso_calc < 180;
                 
  rw_crapepr cr_crapepr%rowtype;  
     
  CURSOR cr_crapdat(pr_cdcooper cecred.crapepr.cdcooper%TYPE) IS
    SELECT crapdat.dtmvtolt     
      FROM cecred.crapdat
     WHERE crapdat.cdcooper = pr_cdcooper;  

  
  vr_cdcritic  NUMBER(3);
  vr_dscritic  VARCHAR2(1000);
  vr_tab_erro  gene0001.typ_tab_erro ;  
  rw_crapdat   btch0001.cr_crapdat%ROWTYPE;
  
  CURSOR c_crapepr(pr_cdcooper in number
                  ,pr_nrdconta in number
                  ,pr_nrctremp in number) IS
    SELECT crapepr.*
          ,TO_CHAR(crapepr.dtdpagto, 'DD') diapagto
          ,crawepr.dtlibera
          ,crawepr.txmensal txmensal_w
          ,crawepr.dtdpagto dtdpagto_w
      FROM crapepr
          ,crawepr
     WHERE crapepr.cdcooper = crawepr.cdcooper
       AND crapepr.nrdconta = crawepr.nrdconta
       AND crapepr.nrctremp = crawepr.nrctremp
       AND crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
  r_crapepr c_crapepr%ROWTYPE; 
  
   CURSOR c_craplcr(pr_cdcooper in number) IS
    SELECT *
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper
       AND craplcr.cdlcremp = r_crapepr.cdlcremp;
  r_craplcr c_craplcr%ROWTYPE; 
  
  PROCEDURE pc_estorno_pagamento(pr_cdcooper IN number
                                ,pr_cdagenci in number
                                ,pr_nrdconta in number
                                ,pr_nrctremp in number
                                ,pr_dtmvtolt in DATE
                                ,pr_vllanmtosai OUT NUMBER
                                ,pr_des_reto OUT VARCHAR
                                ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
    
      TYPE typ_reg_historico IS RECORD (cdhistor craphis.cdhistor%TYPE
                                      , dscritic VARCHAR2(100));
                                      
      TYPE typ_tab_historicos IS TABLE OF typ_reg_historico INDEX BY PLS_INTEGER;
      
      vr_tab_historicos typ_tab_historicos;
      
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
            and lem.dtmvtolt BETWEEN TO_DATE('19/12/2023','dd/mm/yyyy') AND TO_DATE('27/12/2023','dd/mm/yyyy') 
            and lem.cdhistor in (2701  
                                ,2388  
                                ,2473  
                                ,2389  
                                ,2390  
                                ,2475  
                                ,2391);
 
    CURSOR c_busca_prx_lote(pr_dtmvtolt DATE
                           ,pr_cdcooper NUMBER
                           ,pr_cdagenci NUMBER) IS
      SELECT MAX(nrdolote) nrdolote
        FROM craplot
       WHERE craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdcooper = pr_cdcooper
         AND craplot.cdagenci = pr_cdagenci;


    CURSOR c_craplcm (prc_cdcooper craplcm.cdcooper%TYPE,
                      prc_nrdconta craplcm.nrdconta%TYPE,
                      prc_dtmvtolt craplcm.dtmvtolt%TYPE,
                      prc_nrctremp craplem.nrctremp%TYPE,
                      prc_vllanmto craplem.vllanmto%TYPE) IS
      SELECT t.vllanmto
        FROM craplcm t
       WHERE t.cdcooper = prc_cdcooper
         AND t.nrdconta = prc_nrdconta
         AND t.cdhistor = 2386
         AND t.cdbccxlt = 100
         AND to_number(TRIM(REPLACE(REPLACE(t.cdpesqbb, '.', ''),'Desconto de Título do Borderô',''))) = prc_nrctremp
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
           AND t.cdhistor = 2781
           AND t.nrctremp = pr_nrctremp
           AND t.dtmvtolt = pr_dtmvtolt
           AND t.vllanmto = pr_vllanmto;

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
         AND craplcm.cdhistor = 2386
         AND craplcm.cdbccxlt = 100         
         AND to_number(TRIM(REPLACE(REPLACE(craplcm.cdpesqbb, '.', ''),'Desconto de Título do Borderô',''))) = pr_nrctremp
         AND craplcm.vllanmto = pr_vllanmto;
      rw_craplcm cr_craplcm%ROWTYPE;
      

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
         AND crapbpr.cdsitgrv IN (1,4)
         AND crapbpr.flgbaixa = 1
         AND crapbpr.tpdbaixa = 'A';
         
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
       AND vllanmto = pr_vllanmto;
    
    vr_idlancto_2781 NUMBER;
    vr_existbpr_baixado PLS_INTEGER := 0;

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
  BEGIN
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

    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    OPEN cr_crapepr_est(pr_cdcooper, pr_nrdconta, pr_nrctremp);
    FETCH cr_crapepr_est INTO rw_crapepr_est;
    CLOSE cr_crapepr_est;

    OPEN cr_crapbpr_baixado(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp);
    FETCH cr_crapbpr_baixado
     INTO vr_existbpr_baixado;
    CLOSE cr_crapbpr_baixado;
    
    IF vr_existbpr_baixado > 0 THEN
      vr_cdcritic := 0;
      pr_des_reto := 'NOK';
      vr_dscritic := 'Não é permitido estorno, existe baixa da alienação: ';
      raise vr_erro;
    END IF;

    IF nvl(rw_crapepr_est.inprejuz,0) = 0 THEN
      vr_dscritic := 'Não é permitido estorno, empréstimo não está em prejuízo: ';
      raise vr_erro;
    END IF;
    
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

    FOR r_craplem in c_craplem(prc_cdcooper => pr_cdcooper
                              ,prc_nrdconta => pr_nrdconta
                              ,prc_nrctremp => pr_nrctremp
                              ,prc_dtmvtolt => pr_dtmvtolt) LOOP
      IF r_craplem.dtmvtolt = rw_crapdat.dtmvtolt THEN
        IF r_craplem.cdhistor = 2388 THEN
          rw_crapepr_est.vlsdprej := rw_crapepr_est.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2473 THEN
          rw_crapepr_est.vlsdprej := rw_crapepr_est.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2389 THEN
          rw_crapepr_est.vlsdprej := rw_crapepr_est.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2390 THEN
          rw_crapepr_est.vlpgmupr := rw_crapepr_est.vlpgmupr - r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2475 THEN
          rw_crapepr_est.vlpgjmpr := rw_crapepr_est.vlpgjmpr - r_craplem.vllanmto;
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
      END IF;
      ELSE
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

              OPEN c_craplcm (r_craplem.cdcooper,
                                      r_craplem.nrdconta,
                                      r_craplem.dtmvtolt,
                          r_craplem.nrctremp,
                          r_craplem.vllanmto);
              FETCH c_craplcm INTO vr_vllanmto;
              
              IF c_craplcm%NOTFOUND THEN
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
                                          ,pr_cdhistor => 2387
                                          ,pr_vllanmto => vr_vllanmto
                                          ,pr_nrparepr => 0
                                          ,pr_nrctremp => pr_nrctremp
                                          ,pr_nrseqava => 0
                                          ,pr_idlautom => 0
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_tab_erro => vr_tab_erro );
                                          
            pr_vllanmtosai := NVL(vr_vllanmto,0) + NVL(pr_vllanmtosai,0);

            IF vr_des_reto <> 'OK' THEN
              IF vr_tab_erro.count() > 0 THEN
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
                                             ,pr_cdorigem => 7
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);

            IF vr_dscritic is not null THEN
              vr_dscritic := 'Ocorreu falha ao retornar gravacao LEM (' || 
                vr_tab_historicos(r_craplem.cdhistor).dscritic || '): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              raise vr_erro;
            END IF;
            
            
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

        IF r_craplem.cdhistor = 2388 THEN

          rw_crapepr_est.vlsdprej := rw_crapepr_est.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2473 THEN

          rw_crapepr_est.vlsdprej := rw_crapepr_est.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2389 THEN

          rw_crapepr_est.vlsdprej := rw_crapepr_est.vlsdprej + r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2390 THEN

          rw_crapepr_est.vlpgmupr := rw_crapepr_est.vlpgmupr - r_craplem.vllanmto;
        ELSIF r_craplem.cdhistor = 2475 THEN

          rw_crapepr_est.vlpgjmpr := rw_crapepr_est.vlpgjmpr - r_craplem.vllanmto;
        END IF;
      END IF;
    END LOOP;

    OPEN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctremp => pr_nrctremp);
    FETCH cr_crapbpr
     INTO vr_existbpr;
    CLOSE cr_crapbpr;

    IF NVL(vr_existbpr,0) > 0 THEN
      GRVM0001.pc_desfazer_baixa_automatica(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctrpro => pr_nrctremp
                                           ,pr_des_reto => vr_des_reto
                                           ,pr_tab_erro => vr_tab_erro);
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN

          vr_dscritic := 'GRVM001 - ' || vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          pr_des_reto := 'NOK';
          RAISE vr_erro;
        END IF;
      END IF;

    END IF;


    BEGIN
      UPDATE crapepr c
         SET c.vlsdprej = nvl(rw_crapepr_est.vlsdprej,c.vlsdprej) 
            ,c.vlpgjmpr = nvl(rw_crapepr_est.vlpgjmpr,c.vlpgjmpr) 
            ,c.vlpgmupr = nvl(rw_crapepr_est.vlpgmupr,c.vlpgmupr)
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

      ROLLBACK;
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Falha na rotina pc_estorno_pagamento: ';
      END IF;

      pr_des_reto := 'NOK';

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => 0
                           ,pr_nrsequen => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
     when others then
         if vr_dscritic is null then
            vr_dscritic := 'Falha geral rotina pc_estorno_pagamento: ' || sqlerrm;
         end if;

         GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => 'PROCESSO'
                             ,pr_dscritic => vr_dscritic
                             ,pr_dsorigem => 'INTRANET'
                             ,pr_dstransa => 'PREJ0002-Estorno pagamento.'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 0
                             ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => 'crps780'
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);
  END pc_estorno_pagamento;  
  
  Procedure pc_reabrir_conta_corrente(pr_cdcooper in number
                                      ,pr_nrdconta in number
                                      ,pr_cdorigem in number 
                                      ,pr_dtprejuz in date
                                      ,pr_dscritic out varchar2) is
    vr_erro  exception;
        
    begin
      pr_dscritic := 'OK';
  
      BEGIN
        UPDATE CRAPCRM
        SET    CRAPCRM.CDSITCAR = 2 
        ,      CRAPCRM.DTCANCEL = null
        ,      crapcrm.dttransa = pr_dtprejuz
        WHERE  CRAPCRM.CDCOOPER = PR_CDCOOPER
        AND    CRAPCRM.NRDCONTA = PR_NRDCONTA
        AND    CRAPCRM.CDSITCAR = 4; 
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao desbloquear cartao magnetico: ' || sqlerrm;
          raise vr_erro;
        
      END;
     

      BEGIN
        UPDATE CRAPSNH
           SET CRAPSNH.CDSITSNH = 1,
               CRAPSNH.Dtblutsh = NULL,
               crapsnh.dtaltsnh = pr_dtprejuz
         WHERE CRAPSNH.CDCOOPER = PR_CDCOOPER
           AND CRAPSNH.NRDCONTA = PR_NRDCONTA
           AND CRAPSNH.CDSITSNH = 2
           AND crapsnh.tpdsenha = 1
           AND crapsnh.idseqttl = 1;
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao reativar senha internet: ' || sqlerrm;
          raise vr_erro;
        
      END;
      
    exception
      when vr_erro then  
           pr_dscritic := 'erro na rotina de bloqueio de contas';
           
    end pc_reabrir_conta_corrente;
  
  FUNCTION f_valida_pagamento_abono(pr_cdcooper in number
                                   ,pr_nrdconta in number
                                   ,pr_nrctremp in number) RETURN BOOLEAN IS
  
    CURSOR cr_craplcm IS
      SELECT SUM(CASE WHEN c.cdhistor IN (2386) THEN c.vllanmto ELSE 0 END) 
             - 
             SUM(CASE WHEN c.cdhistor IN (2387) THEN c.vllanmto ELSE 0 END) valor_pago
        FROM craplcm c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND to_number(TRIM(REPLACE(REPLACE(c.cdpesqbb, '.', ''),'Desconto de Título do Borderô',''))) = pr_nrctremp
         AND c.cdhistor in(2386,2387); 
     
    CURSOR cr_craplem IS
      SELECT SUM(CASE WHEN c.cdhistor IN (2391) THEN c.vllanmto ELSE 0 END) 
             - 
             SUM(CASE WHEN c.cdhistor IN (2395) THEN c.vllanmto ELSE 0 END) valor_pago_abono
        FROM craplem c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.nrctremp = pr_nrctremp
         AND c.cdhistor IN (2391,2395);    
    
    RESULT BOOLEAN;
    
  BEGIN
    RESULT := FALSE;
    FOR rw_craplcm IN cr_craplcm LOOP
      IF rw_craplcm.valor_pago > 0 THEN
        RESULT := TRUE; 
      END IF;
    END LOOP;
    
    FOR rw_craplem IN cr_craplem LOOP
      IF rw_craplem.valor_pago_abono > 0 THEN
        RESULT := TRUE; 
      END IF;
    END LOOP;
  
  RETURN(RESULT);
  END f_valida_pagamento_abono;
  
  PROCEDURE pc_estorno_trf_prejuizo_PP(pr_cdcooper IN NUMBER
                                       ,pr_cdagenci IN NUMBER
                                       ,pr_nrdcaixa IN NUMBER
                                       ,pr_cdoperad IN VARCHAR2
                                       ,pr_nrdconta IN NUMBER
                                       ,pr_dtmvtolt IN DATE
                                       ,pr_nrctremp IN NUMBER
                                       ,pr_vllanmtosai_princ OUT NUMBER
                                       ,pr_des_reto OUT VARCHAR 
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS

    CURSOR cr_craplem2(pr_dtmvtolt IN DATE) IS
      SELECT * 
        FROM craplem
       WHERE craplem.cdcooper = pr_cdcooper
         AND craplem.nrdconta = pr_nrdconta
         AND craplem.nrctremp = pr_nrctremp
         AND craplem.dtmvtolt = pr_dtmvtolt
         AND craplem.cdbccxlt = 100;
       
       rw_craplem cr_craplem2%rowtype;


    CURSOR cr_lanc_lem (prc_cdcooper craplem.cdcooper%TYPE
                       ,prc_nrdconta craplem.nrdconta%TYPE
                       ,prc_nrctremp craplem.nrctremp%TYPE) IS                  
      SELECT NVL((SUM(CASE WHEN c.cdhistor IN (2382, 2882,2954,2953,2883) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2384) THEN c.vllanmto ELSE 0 END)),0) sum_jr60_2382,
             NVL((SUM(CASE WHEN c.cdhistor IN (2397, 2886,2956,2955,2887) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2399) THEN c.vllanmto ELSE 0 END)),0) sum_jr60_2397,
             NVL((SUM(CASE WHEN c.cdhistor IN (2409) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2422) THEN c.vllanmto ELSE 0 END)),0) sum_jratz_2409,
             NVL((SUM(CASE WHEN c.cdhistor IN (2411) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2423) THEN c.vllanmto ELSE 0 END)),0) sum_jrmulta_2411,
             NVL((SUM(CASE WHEN c.cdhistor IN (2415) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2416) THEN c.vllanmto ELSE 0 END)),0) sum_jrmora_2415,
             nvl((SUM(CASE WHEN c.cdhistor IN (2348) THEN c.vllanmto ELSE 0 END) 
                - SUM(CASE WHEN c.cdhistor IN (2472) THEN c.vllanmto ELSE 0 END)),0) sum_jrmult_2348,
             nvl((SUM(CASE WHEN c.cdhistor IN (2349) THEN c.vllanmto ELSE 0 END) 
                - SUM(CASE WHEN c.cdhistor IN (2359) THEN c.vllanmto ELSE 0 END)), 0) sum_jrmult_2349                   
        FROM craplem c
       WHERE c.cdcooper = prc_cdcooper
         AND c.nrdconta = prc_nrdconta
         AND c.nrctremp = prc_nrctremp
         AND c.cdhistor in (2382,2384,2397,2399,2409,2422,2411,2423,2415,2416, 2348,2472,2349,2359, 2882,2954,2953,2883, 2886,2956,2955,2887)
         AND c.dtmvtolt >= TO_DATE('19/12/2023','DD/MM/YYYY'); 
    
    CURSOR cr_vlprincipal (prc_cdcooper craplem.cdcooper%TYPE
                          ,prc_nrdconta craplem.nrdconta%TYPE
                          ,prc_nrctremp craplem.nrctremp%TYPE) IS
                  
      SELECT NVL((SUM(CASE WHEN c.cdhistor IN (2381, 2878) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2383) THEN c.vllanmto ELSE 0 END)),0) sum_empr_2381, 
             NVL((SUM(CASE WHEN c.cdhistor IN (2396, 2885) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2398) THEN c.vllanmto ELSE 0 END)),0) sum_fina_2396          
        FROM craplem c
       WHERE c.cdcooper = prc_cdcooper
         AND c.nrdconta = prc_nrdconta
         AND c.nrctremp = prc_nrctremp
         AND c.cdhistor in (2381,2396,2383,2398, 2878,2885);          
   
    CURSOR cr_crapepr (prc_cdcooper craplem.cdcooper%TYPE
                      ,prc_nrdconta craplem.nrdconta%TYPE) IS
      SELECT DISTINCT 1 existe
        FROM crapepr epr
       WHERE epr.cdcooper = prc_cdcooper
         AND epr.nrdconta = prc_nrdconta 
         AND epr.inprejuz = 1
         AND epr.dtprejuz IS NOT NULL
         AND epr.cdlcremp <> 100;
           
    vr_cdhistor1 INTEGER;
    vr_flgtrans  BOOLEAN;
    vr_dstransa  VARCHAR2(500);
    vr_dtmvtolt  DATE;
    vr_auxvalor  NUMBER;
    vr_vljuro60  NUMBER;
    vr_cdhisatz  INTEGER;
    vr_vljratuz  NUMBER;
    vr_cdhismul  INTEGER;
    vr_vljrmult  NUMBER;
    vr_cdhismulp INTEGER;
    vr_vljrmultp NUMBER;    
    vr_cdhismor  INTEGER;
    vr_vljrmora  NUMBER;
    vr_vlprinci  NUMBER;
    vr_vllanmtosai_princ NUMBER := 0;
    vr_nrdrowid  ROWID;
    vr_exc_erro  EXCEPTION; 
    vr_existe_prejuizo NUMBER(1);  
       
  BEGIN
    vr_flgtrans := FALSE;
    pr_des_reto := 'OK';
             
   
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
             
    
    OPEN c_crapepr(pr_cdcooper
                 ,pr_nrdconta
                 ,pr_nrctremp);
    FETCH c_crapepr INTO r_crapepr;

    IF c_crapepr%FOUND THEN
      CLOSE c_crapepr;
     IF f_valida_pagamento_abono(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp) THEN
                                       
       pc_estorno_pagamento(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => 1,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp,
                            pr_dtmvtolt => rw_crapdat.dtmvtolt,
                            pr_vllanmtosai => pr_vllanmtosai_princ,
                            pr_des_reto => vr_des_reto,
                            pr_tab_erro => vr_tab_erro);    
                     
        IF vr_des_reto <> 'OK' THEN

          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao Estornar Pagamento!';

          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

          pr_des_reto := 'NOK';
        END IF;                       
      END IF;
      
      IF r_crapepr.inprejuz = 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Contrato não esta em prejuizo!';

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';
        RAISE vr_exc_erro;
      ELSE
        
        vr_dtmvtolt := r_crapepr.dtprejuz;
        
        
        IF r_crapepr.tpemprst = 1 and r_crapepr.tpdescto = 2 THEN
           EMPR0020.pc_estorna_prejuizo_fis(pr_cdcooper => pr_cdcooper,
                                            pr_cdagenci => pr_cdagenci,
                                            pr_nrdcaixa => pr_nrdcaixa,
                                            pr_cdoperad => pr_cdoperad,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_nrctremp => pr_nrctremp,
                                            pr_des_reto => vr_des_reto,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);

           IF vr_des_reto <> 'OK' THEN
             RAISE vr_exc_erro;
           END IF;          
        END IF;

       
        RATI0001.pc_verifica_contrato_rating(pr_cdcooper =>  pr_cdcooper
                                            ,pr_cdagenci => 0
                                           , pr_nrdcaixa => 0
                                           , pr_cdoperad => pr_cdoperad
                                           , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           , pr_dtmvtopr => rw_crapdat.dtmvtopr
                                           , pr_nrdconta => pr_nrdconta
                                           , pr_tpctrrat => 90
                                           , pr_nrctrrat => pr_nrctremp
                                           , pr_idseqttl => 1
                                           , pr_idorigem => 7 
                                           , pr_nmdatela => 'CRPS780'
                                           , pr_inproces => 0
                                           , pr_flgerlog => true
                                           , pr_tab_erro => vr_tab_erro
                                           , pr_des_erro => vr_des_reto
                                           , pr_dscritic => vr_dscritic);
                     
        IF vr_des_reto <> 'OK' THEN

          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao ativar Rating!';

          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

             pr_des_reto := 'NOK';
        END IF;
                    
      
        FOR rw_craplem IN cr_craplem2(vr_dtmvtolt) LOOP
          vr_auxvalor :=0;
                        
          IF r_crapepr.vlprejuz > 0 AND rw_craplem.cdhistor IN (1732, 1731) THEN
             vr_auxvalor := r_crapepr.vlprejuz;
          END IF;
                        
          IF r_crapepr.vlttmupr > 0 AND rw_craplem.cdhistor IN (1734, 1733) THEN
            vr_auxvalor := r_crapepr.vlttmupr;
          END IF;
                        
          IF r_crapepr.vlttjmpr > 0 AND rw_craplem.cdhistor IN (1736, 1735) THEN
            vr_auxvalor := r_crapepr.vlttjmpr;
          END IF;
          
        END LOOP;
            
        IF r_crapepr.dtprejuz = rw_crapdat.dtmvtolt THEN
          
          IF vr_auxvalor > 0 THEN
            BEGIN
              UPDATE craplot 
                 SET craplot.nrseqdig = craplot.nrseqdig +  1
                    ,craplot.qtcompln = craplot.qtcompln -1
                    ,craplot.qtinfoln = craplot.qtinfoln -1
                    ,craplot.vlcompcr = craplot.vlcompcr + (vr_auxvalor * -1)
                    ,craplot.vlinfocr = craplot.vlinfocr + (vr_auxvalor * -1)
               WHERE craplot.cdcooper = rw_craplem.cdcooper
                 AND   craplot.cdagenci = rw_craplem.cdagenci
                 AND   craplot.cdbccxlt = rw_craplem.cdbccxlt
                 AND   craplot.nrdolote = rw_craplem.nrdolote
                 AND   craplot.dtmvtolt = rw_crapdat.dtmvtolt
                 AND   craplot.tplotmov = 5;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar lote!' || sqlerrm;
                vr_des_reto := 'NOK';
                RAISE vr_exc_erro;
            END;
                                 
          END IF;       
                       
         
          BEGIN
             DELETE FROM CRAPLEM
              WHERE craplem.cdcooper = pr_cdcooper
                AND craplem.nrdconta = pr_nrdconta
                AND craplem.nrctremp = pr_nrctremp
                AND craplem.dtmvtolt = rw_crapdat.dtmvtolt
                AND craplem.cdbccxlt = 100
                AND craplem.cdhistor in (2381,2382,2411,2415,2385,2396,2397,2400,2735);
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro na exclusão dos lançamentos!' || sqlerrm;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
          END;
                       
        ELSE 
          OPEN c_craplcr(pr_cdcooper);
          FETCH c_craplcr INTO r_craplcr;

          IF c_craplcr%NOTFOUND THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Linha de Credito nao Cadastrada!';
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
          CLOSE c_craplcr;
        
          BEGIN
            UPDATE crapcyb cyb
               SET cyb.vlsdevan = r_crapepr.vlsdeved
                  ,cyb.vlsdeved = r_crapepr.vlsdeved
                  ,cyb.qtprepag = r_crapepr.qtprecal
                  ,cyb.txmensal = r_crapepr.txmensal
                  ,cyb.txdiaria = r_crapepr.txjuremp
                  ,cyb.dtprejuz = null
                  ,cyb.vlsdprej = 0
                  ,cyb.vlpreemp = r_crapepr.vlpreemp
             WHERE cyb.cdcooper = pr_cdcooper
               AND cyb.nrdconta = pr_nrdconta
               AND cyb.nrctremp = pr_nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Falha ao atualizar tabela CYBER! PP' || sqlerrm;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;                    
          END;   
         
          FOR rw_vlprincipal IN cr_vlprincipal(pr_cdcooper,
                                               pr_nrdconta,
                                               pr_nrctremp) LOOP
            
            IF rw_vlprincipal.sum_empr_2381 > 0 THEN
              vr_cdhistor1 := 2383;
              vr_vlprinci := rw_vlprincipal.sum_empr_2381;
            ELSE
              vr_cdhistor1 := 2398;
              vr_vlprinci := rw_vlprincipal.sum_fina_2396;
            END IF;
           
            IF vr_vlprinci > 0 THEN
              
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhistor1
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vlprinci
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                                 
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor principal): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END LOOP;

   
  
          FOR rw_lanc_lem IN cr_lanc_lem(pr_cdcooper,
                                         pr_nrdconta,
                                         pr_nrctremp) LOOP
            
            IF rw_lanc_lem.sum_jr60_2382 > 0 THEN
              vr_cdhistor1 := 2384;
              vr_vljuro60 := rw_lanc_lem.sum_jr60_2382;
            END IF;

            IF rw_lanc_lem.sum_jr60_2397 > 0 THEN
              vr_cdhistor1 := 2399;
              vr_vljuro60 := rw_lanc_lem.sum_jr60_2397;
            END IF;
         
            IF rw_lanc_lem.sum_jratz_2409 > 0 THEN
              vr_cdhisatz := 2422;
              vr_vljratuz := rw_lanc_lem.sum_jratz_2409;
            END IF;
         
            IF rw_lanc_lem.sum_jrmulta_2411 > 0 THEN
              vr_cdhismul := 2423;
              vr_vljrmult := rw_lanc_lem.sum_jrmulta_2411;
            END IF;
          
            IF rw_lanc_lem.sum_jrmora_2415 > 0 THEN
              vr_cdhismor := 2416;
              vr_vljrmora := rw_lanc_lem.sum_jrmora_2415;
            END IF;    

           IF rw_lanc_lem.sum_jrmult_2348 > 0 THEN
             vr_cdhismulp := 2472;
             vr_vljrmultp := rw_lanc_lem.sum_jrmult_2348;
           END IF;

           IF rw_lanc_lem.sum_jrmult_2349 > 0 THEN
             vr_cdhismulp := 2359;
             vr_vljrmultp := rw_lanc_lem.sum_jrmult_2349;
           END IF;            
         
            IF vr_vljuro60 > 0 THEN
             
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhistor1
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljuro60
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                                 
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM PP(Juros +60): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;

            IF vr_vljratuz > 0 THEN

              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhisatz
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljratuz
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                                 
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM PP (Juros Atualizado): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
             
         
            IF vr_vljrmult > 0 THEN
             
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhismul
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljrmult
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                                 
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM PP (valor Multa): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;

            IF vr_vljrmultp > 0 THEN
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper,
                                              pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                              pr_cdagenci => pr_cdagenci,
                                              pr_cdbccxlt => 100,
                                              pr_cdoperad => pr_cdoperad,
                                              pr_cdpactra => pr_cdagenci,
                                              pr_tplotmov => 5,
                                              pr_nrdolote => 600029,
                                              pr_nrdconta => pr_nrdconta,
                                              pr_cdhistor => vr_cdhismulp,
                                              pr_nrctremp => pr_nrctremp,
                                              pr_vllanmto => vr_vljrmultp,
                                              pr_dtpagemp => rw_crapdat.dtmvtolt,
                                              pr_txjurepr => 0,
                                              pr_vlpreemp => 0,
                                              pr_nrsequni => 0,
                                              pr_nrparepr => 0,
                                              pr_flgincre => TRUE,
                                              pr_flgcredi => FALSE,
                                              pr_nrseqava => 0,
                                              pr_cdorigem => 7
                                             ,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);
    
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM PÓS (Multa da operação): ' ||
                               vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
                      
            IF vr_vljrmora > 0 THEN
 
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhismor
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljrmora
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                                 
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM PP (Juros Mora): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;                                    
          END LOOP;          
                 
        END IF;
       
        BEGIN
             UPDATE CRAPPEP
             SET    crappep.inliquid = 0
             ,      crappep.inprejuz = 0
             where  crappep.cdcooper = pr_cdcooper
             and    crappep.nrdconta = pr_nrdconta
             and    crappep.nrctremp = pr_nrctremp
             and    crappep.inliquid = 1
             and    crappep.inprejuz = 1; 
                      
        EXCEPTION
          when others then
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar parcelas!' || sqlerrm;
            pr_des_reto := 'NOK';
            raise vr_exc_erro;
        END;  
                  
                        
        BEGIN
           UPDATE CRAPEPR
              SET crapepr.vlsdeved = crapepr.vlprejuz
                 ,crapepr.vlsdevat = crapepr.vlsdprej
                 ,crapepr.vlprejuz = 0
                 ,crapepr.vlsdprej = 0
                 ,crapepr.inprejuz = 0
                 ,crapepr.inliquid = 0
                 ,crapepr.dtprejuz = null
                 ,crapepr.vlttmupr = 0
                 ,crapepr.vlttjmpr = 0
                 ,crapepr.vlpgmupr = 0
                 ,crapepr.vlpgjmpr = 0
                 ,crapepr.vltiofpr = 0
                 ,crapepr.vliofpriantprej = 0
                 ,crapepr.vliofadiantprej = 0
            WHERE crapepr.cdcooper = pr_cdcooper
              AND crapepr.nrdconta = pr_nrdconta
              AND crapepr.nrctremp = pr_nrctremp
              AND crapepr.inprejuz = 1; 
                     
        EXCEPTION
          when others then
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar emprestimo!' || sqlerrm;
              pr_des_reto := 'NOK';
              raise vr_exc_erro;
        END;
                     
        vr_dstransa := 'Data: ' || to_char( pr_dtmvtolt,'DD/MM/YYYY') ||
                       ' - Estorno de transferencia para prejuizo PP - ' ||
                       ', Conta:  ' || pr_nrdconta || 
                       ', Contrato: ' || pr_nrctremp;
                  
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => pr_cdoperad
                             ,pr_dscritic => null
                             ,pr_dsorigem => 'AIMARO'
                             ,pr_dstransa => vr_dstransa
                             ,pr_dttransa => pr_dtmvtolt
                             ,pr_flgtrans => 1
                             ,pr_hrtransa => gene0002.fn_busca_time
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => 'CRPS780'
                             ,pr_nrdconta => PR_NRDCONTA
                             ,pr_nrdrowid => VR_NRDROWID);

        vr_flgtrans := TRUE;

      END IF;
      
      vr_existe_prejuizo := 0;
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper,
                                   pr_nrdconta) LOOP
        vr_existe_prejuizo := 1; 
      END LOOP;
        
      IF vr_existe_prejuizo = 0 THEN
        rw_crapdat.dtmvtolt := r_crapepr.dtprejuz;
                
        pc_reabrir_conta_corrente(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_cdorigem => 3
                                 ,pr_dtprejuz => rw_crapdat.dtmvtolt 
                                 ,pr_dscritic => vr_dscritic);
                                             
        IF vr_dscritic is not null AND vr_dscritic <> 'OK' then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao desbloquear conta corrente. ' || sqlerrm;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
            pr_des_reto := 'NOK';
        END IF;     
      END IF; 
                  
    ELSE  
      CLOSE c_crapepr;
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao estornar prejuizo PP: ' || sqlerrm;
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                          ,pr_cdagenci => pr_cdagenci
                          ,pr_nrdcaixa => pr_nrdcaixa
                          ,pr_nrsequen => 1 
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic
                          ,pr_tab_erro => pr_tab_erro);
      pr_des_reto := 'NOK';
    END IF;

    IF NOT vr_flgtrans THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao estornar Prejuizo.';
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
     pr_des_reto := 'NOK';
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      
      ROLLBACK;
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Erro na rotina pc_estorno_trf_prejuizo_PP: '; 
      END IF;
           
     
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => 'PREJ0001-Estorno transferencia.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'crps780'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
         
  END pc_estorno_trf_prejuizo_PP;   
  
BEGIN

  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_format = ''DD/MM/RRRR''';
  
  FOR rw_crapepr IN cr_crapepr LOOP
                              

     OPEN btch0001.cr_crapdat(rw_crapepr.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
     OPEN cr_acordo(rw_crapepr.Cdcooper,
                    rw_crapepr.nrdconta,
                    rw_crapepr.nrctremp);
    FETCH cr_acordo INTO rw_acordo;
    CLOSE cr_acordo;        
                                                                      
    IF rw_crapepr.tpemprst IN (1, 2) THEN
      
      /*pc_estorno_trf_prejuizo_PP(pr_cdcooper => rw_crapepr.Cdcooper,
                                 pr_cdagenci => 1,
                                 pr_nrdcaixa => 1,
                                 pr_cdoperad => '1',
                                 pr_nrdconta => rw_crapepr.nrdconta,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                 pr_nrctremp => rw_crapepr.nrctremp,
                                 pr_vllanmtosai_princ => vr_vllanmtosai_princ,
                                 pr_des_reto => vr_des_reto,
                                 pr_tab_erro => vr_tab_reto);      
      */

      vr_vllanmtosai_princ := 1800;

      IF NVL(vr_vllanmtosai_princ,0) > 0 THEN                           

        recp0001.pc_pagar_contrato_emprestimo(pr_cdcooper => rw_crapepr.Cdcooper,
                                              pr_nrdconta => rw_crapepr.nrdconta,
                                              pr_cdagenci => 1,
                                              pr_crapdat => rw_crapdat,
                                              pr_nrctremp => rw_crapepr.nrctremp,
                                              pr_nracordo => rw_acordo.nracordo,
                                              pr_nrparcel => rw_acordo.nrparcela,
                                              pr_cdoperad => '1',
                                              pr_vlparcel => NVL(vr_vllanmtosai_princ,0),
                                              pr_idorigem => 7,
                                              pr_nmtelant => 'ATENDA',
                                              pr_idvlrmin => vr_idvlrmin,
                                              pr_vltotpag => vr_vltotpag,
                                              pr_cdcritic => vr_cdcritica,
                                              pr_dscritic => vr_dscritica);
      END IF;                                        
    COMMIT;                                                                                                                                                                                                                                                                                                
    END IF;
  END LOOP;
EXCEPTION                                         
  WHEN OTHERS THEN
    ROLLBACK; 
    RAISE_application_error(-20500, 'Erro: ' || SQLERRM);
END;
