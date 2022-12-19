BEGIN
  DECLARE
    CURSOR cr_crapcop IS
      SELECT c.cdcooper 
      FROM CRAPCOP c
      WHERE
           c.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    CURSOR cr_consig_movimento (pr_dtmovimento tbepr_consig_parcelas_tmp.dtmovimento%TYPE, 
                                pr_cdcooper crappep.cdcooper%TYPE) IS
      SELECT tcm.cdcooper,
             tcm.nrdconta,
             tcm.nrctremp,
             tcm.nrparcela,
             NVL(tec.indautrepassecc,0) indautrepassecc,
             decode(tcm.intplancamento,3,2,
                    decode(tcm.intplancamento,12,11,tcm.intplancamento)) intplancamento,
             tcm.instatusproces,
             tcm.dserroproces,
             MIN(tcm.dtmovimento) dtmovimento,
             MIN(tcm.dtgravacao)  dtgravacao,
             MAX(epr.txjuremp) txjuremp,
             MIN(epr.vlpreemp) vlpreemp,
             MIN(epr.dtrefjur) dtrefjur,
             SUM(NVL(tcm.vldebito,0)) vldebito,
             SUM(NVL(tcm.vlcredito,0)) vlcredito,
             SUM(NVL(tcm.vlsaldo,0)) vlsaldo,
             (SELECT NVL(SUM(nvl(aux.vlsaldo,0)),0)
                FROM tbepr_consig_movimento_tmp aux
               WHERE tcm.cdcooper    = aux.cdcooper
                 AND tcm.nrdconta    = aux.nrdconta
                 AND tcm.nrctremp    = aux.nrctremp
                 AND tcm.dtmovimento = aux.dtmovimento
                 AND tcm.nrparcela   = aux.nrparcela
                 AND aux.intplancamento = 7) vldesconto,
             (SELECT NVL(SUM(nvl(aux.vlsaldo,0)),0)
                FROM tbepr_consig_movimento_tmp aux
               WHERE tcm.cdcooper    = aux.cdcooper
                 AND tcm.nrdconta    = aux.nrdconta
                 AND tcm.nrctremp    = aux.nrctremp
                 AND tcm.dtmovimento = aux.dtmovimento
                 AND tcm.nrparcela   = aux.nrparcela
                 AND aux.intplancamento = 16) vlestdesconto,
             epr.inprejuz,
             tcm.dsmotivo,
             tcm.idintegracao,
             epr.inliquid
        FROM tbepr_consig_movimento_tmp tcm,
             crapepr epr,
             tbcadast_empresa_consig tec
       WHERE tcm.cdcooper    = epr.cdcooper
         AND tcm.nrdconta    = epr.nrdconta
         AND tcm.nrctremp    = epr.nrctremp 
         AND epr.cdcooper    = tec.cdcooper(+)
         AND epr.cdempres    = tec.cdempres(+)
         and tcm.dtmovimento = pr_dtmovimento
         AND tcm.cdcooper    = pr_cdcooper
         AND tcm.intplancamento not in (1,8)
         AND exists (SELECT 1
                       FROM tbepr_consig_contrato_tmp tcc
                      WHERE tcc.cdcooper    = pr_cdcooper
                        AND (tcc.dtmovimento = pr_dtmovimento OR tcc.instatuscontr = 2)
                        AND tcc.nrdconta = tcm.nrdconta
                        AND tcc.nrctremp = tcm.nrctremp
                        AND tcc.vlsdev_empratu_d0 <= 199999.99
                        AND tcc.vlsdev_empratu_d1 <= 199999.99
                        )
         AND NVL(tcm.instatusproces,'W') <> 'P'
    GROUP BY tcm.cdcooper,
             tcm.nrdconta,
             tcm.nrctremp,
             tcm.nrparcela,
             NVL(tec.indautrepassecc,0),
             decode(tcm.intplancamento,3,2,
                    decode(tcm.intplancamento,12,11,tcm.intplancamento)),
             tcm.instatusproces,
             tcm.dserroproces,
             tcm.dtmovimento,
             epr.inprejuz,
             tcm.dsmotivo,
             tcm.idintegracao,
             epr.inliquid
   ORDER BY  tcm.cdcooper,
             tcm.nrdconta,
             tcm.nrctremp,
             tcm.nrparcela;

    CURSOR cr_vecto_parc (pr_cdcooper IN crappep.cdcooper%TYPE,
                          pr_nrdconta IN crappep.nrdconta%TYPE,
                          pr_nrctremp IN crappep.nrctremp%TYPE,
                          pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                          pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) IS
    SELECT 'S' vr_existe
      FROM crappep pep
     WHERE pep.cdcooper = pr_cdcooper
       AND pep.nrdconta = pr_nrdconta
       AND pep.nrctremp = pr_nrctremp
       AND pep.dtvencto >  pr_dtmvtoan
       AND pep.dtvencto <= pr_dtmvtolt
       AND pep.inliquid = 0;

    rw_vecto_parc  cr_vecto_parc%ROWTYPE;

    CURSOR cr_craplcrepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                          pr_nrdconta IN crapepr.nrdconta%TYPE,
                          pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT lcr.dsoperac
      FROM craplcr lcr,
           crapepr epr
     WHERE epr.cdcooper = lcr.cdcooper
       AND epr.cdlcremp = lcr.cdlcremp
       AND epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;

    rw_craplcrepr cr_craplcrepr%ROWTYPE;

    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT ass.cdagenci
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;

    rw_crapass cr_crapass%ROWTYPE;


    CURSOR cr_consignado_pagto (pr_cdcooper IN tbepr_consignado_pagamento.cdcooper%TYPE,
                                pr_nrdconta IN tbepr_consignado_pagamento.nrdconta%TYPE,
                                pr_nrctremp IN tbepr_consignado_pagamento.nrctremp%TYPE,
                                pr_nrparepr IN tbepr_consignado_pagamento.nrparepr%TYPE,
                                pr_dtmvtolt IN tbepr_consignado_pagamento.dtmvtolt%TYPE,
                                pr_dsmotivo IN VARCHAR2,
                                pr_idintegracao IN tbepr_consignado_pagamento.Idintegracao%TYPE) IS
    
       
    SELECT 1 vr_existe
      FROM tbepr_consignado_pagamento tcp
     WHERE tcp.cdcooper = pr_cdcooper
       AND tcp.nrdconta = pr_nrdconta
       AND tcp.nrctremp = pr_nrctremp
       AND tcp.nrparepr = pr_nrparepr
       AND ((nvl(pr_dsmotivo,'M') = 'REENVIARPAGTO'
             AND tcp.idsequencia =(SELECT max(consig_pgto.idsequencia)                
                                     FROM tbepr_consignado_pagamento consig_pgto
                                    WHERE consig_pgto.cdcooper     = tcp.cdcooper
                                      AND consig_pgto.nrdconta     = tcp.nrdconta
                                      AND consig_pgto.nrctremp     = tcp.nrctremp
                                      AND consig_pgto.idseqpagamento is null
                                      AND consig_pgto.idintegracao = pr_idintegracao
                                      AND consig_pgto.Instatus     = 2  
                                      )
             ) 
            OR (nvl(pr_dsmotivo,'M') <> 'REENVIARPAGTO' 
                AND tcp.dtmvtolt = pr_dtmvtolt));  

     rw_consignado_pagto cr_consignado_pagto%ROWTYPE;


    CURSOR cr_juros_rem (pr_cdcooper IN tbepr_consig_movimento_tmp.cdcooper%TYPE,
                         pr_nrdconta IN tbepr_consig_movimento_tmp.nrdconta%TYPE,
                         pr_nrctremp IN tbepr_consig_movimento_tmp.nrctremp%TYPE,
                         pr_nrparepr IN tbepr_consig_movimento_tmp.nrparcela%TYPE,
                         pr_dtmovimento in tbepr_consig_movimento_tmp.dtmovimento%TYPE) IS
     SELECT NVL(SUM(nvl(tcm.vlsaldo,0)),0) vljurosrem
       FROM tbepr_consig_movimento_tmp tcm
      WHERE tcm.cdcooper    = pr_cdcooper
        AND tcm.nrdconta    = pr_nrdconta
        AND tcm.nrctremp    = pr_nrctremp
        AND tcm.nrparcela   = pr_nrparepr
        AND tcm.dtmovimento<= pr_dtmovimento
        AND NVL(tcm.instatusproces,'W') <> 'P'
        AND tcm.intplancamento = 10; 

    CURSOR cr_crapcot (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE) IS
     SELECT crapcot.ROWID
       FROM crapcot
      WHERE crapcot.cdcooper = pr_cdcooper
        AND crapcot.nrdconta = pr_nrdconta;
       rw_crapcot cr_crapcot%ROWTYPE;

    CURSOR cr_crapmfx (pr_cdcooper IN crapmfx.cdcooper%TYPE
                      ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                      ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
     SELECT mfx.cdcooper,
            mfx.vlmoefix
       FROM crapmfx mfx
      WHERE mfx.cdcooper = pr_cdcooper
        AND mfx.dtmvtolt = pr_dtmvtolt
        AND mfx.tpmoefix = pr_tpmoefix;
     rw_crapmfx cr_crapmfx%ROWTYPE;
 

    CURSOR cr_maior_dtmvtolt_craplem(pr_cdcooper craplem.cdcooper%TYPE
                     ,pr_nrdconta craplem.nrdconta%TYPE
                     ,pr_nrctremp craplem.nrctremp%TYPE
                     ) IS
      select max(dtmvtolt) dtmvtolt
        from craplem crapx
       where crapx.cdcooper = pr_cdcooper
         and crapx.nrdconta = pr_nrdconta
         and crapx.nrctremp = pr_nrctremp
         and crapx.cdhistor in (1038,1037);


    CURSOR cr_contrato_liquidado(pr_cdcooper crappep.cdcooper%TYPE
                     ,pr_nrdconta crappep.nrdconta%TYPE
                     ,pr_nrctremp crappep.nrctremp%TYPE ) IS

      select nvl(max(0),1) inliquid
        from crappep cpp
       where cpp.inliquid = 0 
         and cpp.cdcooper = pr_cdcooper
         and cpp.nrdconta = pr_nrdconta
         and cpp.nrctremp = pr_nrctremp;

    vr_cdprogra        CONSTANT crapprg.cdprogra%TYPE:= 'CRPS782';

    vr_cdcritic        INTEGER:= 0;
    vr_dscritic        VARCHAR2(4000);

    vr_exc_saida       EXCEPTION;

    TYPE typ_tbepr_consig_parcelas_tmp IS TABLE OF tbepr_consig_parcelas_tmp%ROWTYPE INDEX BY VARCHAR2(40);
    vr_tab_parcelas      typ_tbepr_consig_parcelas_tmp;

    TYPE typ_tab_pagto IS TABLE OF NUMBER INDEX BY VARCHAR2(40);
    vr_tab_pagto        typ_tab_pagto;

    TYPE typ_tab_pagto_ctr IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
    vr_tab_pagto_ctr        typ_tab_pagto_ctr;

    TYPE typ_reg_inorigem IS RECORD(inorigem NUMBER);
    TYPE typ_tab_inorigem IS
      TABLE OF typ_reg_inorigem
       INDEX BY VARCHAR2(40);
    vr_tab_inorigem       typ_tab_inorigem;
    vr_index_inorigem     VARCHAR2(40);

    pr_cdcritic           crapcri.cdcritic%TYPE;
    pr_dscritic           varchar2(250);
    vr_dtmvtctr           tbepr_consig_contrato_tmp.dtmovimento%TYPE;
    vr_floperac           Boolean;
    vr_cdhistor           craplem.cdhistor%TYPE;
    vr_cdhistor_es        craplem.cdhistor%TYPE;
    vr_cdhistorrem        craplem.cdhistor%TYPE;
    vr_nrdolote           craplem.nrdolote%TYPE;
    vr_cdoperad           crapope.cdoperad%TYPE:= '1';
    vr_cdorigem           craplem.cdorigem%TYPE;
    vr_jurosrem           craplem.vllanmto%TYPE;
    vr_dtmvtolt           crapdat.dtmvtolt%TYPE;
    vr_dtmvtolt_lanc      crapdat.dtmvtolt%TYPE;
    vr_dtmvtoan           crapdat.dtmvtoan%TYPE;
    vr_dtmvtopr           crapdat.dtmvtopr%TYPE;
    vr_inproces           crapdat.inproces%TYPE;
    vr_vlmovimento        craplem.vllanmto%TYPE;
    vr_contrato_liquidado number(1);
    vr_maior_dtmvtolt     craplem.dtmvtolt%type;
    rw_crapdat            BTCH0001.cr_crapdat%ROWTYPE;

    FUNCTION fn_busca_hist_estorno (pr_cdcooper IN craphis.cdcooper%TYPE,
                                    pr_cdhistor IN craphis.cdhistor%TYPE) RETURN NUMBER IS
      CURSOR cr_craphis IS
       SELECT cdhisest
         FROM craphis
        WHERE craphis.cdcooper = pr_cdcooper
          AND craphis.cdhistor = pr_cdhistor;

      vr_cdhisest craphis.cdhisest%TYPE;
    BEGIN
      vr_cdhisest:= null;
      FOR rw_craphis IN cr_craphis
      LOOP
        vr_cdhisest:= rw_craphis.cdhisest;
      END LOOP;
      RETURN (vr_cdhisest);
    END;

  BEGIN    
    vr_inproces:= 3;
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    vr_tab_inorigem.DELETE;
    vr_tab_parcelas.DELETE;
    vr_tab_pagto_ctr.DELETE;
    vr_tab_pagto.DELETE;
    
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
    
    vr_dtmvtoan:= to_date('13/12/2022', 'DD/MM/YYYY');
    vr_dtmvtolt:= to_date('14/12/2022', 'DD/MM/YYYY');
    vr_dtmvtopr:= to_date('15/12/2022', 'DD/MM/YYYY');
    vr_dtmvtolt_lanc:= rw_crapdat.dtmvtolt;
    vr_dtmvtctr:= vr_dtmvtolt;

    IF vr_inproces > 1 THEN
       FOR rw_crapcop IN cr_crapcop 
       LOOP
           
          pr_cdcritic:= NULL;
          pr_dscritic:= NULL;
          vr_tab_inorigem.DELETE;

          FOR rw_consig_movimento IN cr_consig_movimento (pr_dtmovimento => vr_dtmvtctr, pr_cdcooper => rw_crapcop.cdcooper)
          LOOP
            OPEN cr_craplcrepr(pr_cdcooper => rw_consig_movimento.cdcooper,
                               pr_nrdconta => rw_consig_movimento.nrdconta,
                               pr_nrctremp => rw_consig_movimento.nrctremp);
            FETCH cr_craplcrepr
            INTO rw_craplcrepr;
            IF cr_craplcrepr%NOTFOUND THEN
               CLOSE cr_craplcrepr;
               vr_cdcritic := 1178;
               vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                rw_consig_movimento.nrctremp||'/'||
                                                rw_consig_movimento.nrparcela||'/'||
                                                rw_consig_movimento.intplancamento||')';
                                                
               btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                         ,pr_ind_tipo_log => 2
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' >>> '
                                                            || vr_dscritic );
              RAISE vr_exc_saida;
            ELSE
               CLOSE cr_craplcrepr;
            END IF;
            vr_floperac := rw_craplcrepr.dsoperac = 'FINANCIAMENTO';

            OPEN cr_crapass(pr_cdcooper => rw_consig_movimento.cdcooper,
                            pr_nrdconta => rw_consig_movimento.nrdconta);
            FETCH cr_crapass
            INTO rw_crapass;
            IF cr_crapass%NOTFOUND THEN
               CLOSE cr_crapass;
               vr_cdcritic := 1042;
               vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                rw_consig_movimento.nrctremp||'/'||
                                                rw_consig_movimento.nrparcela||'/'||
                                                rw_consig_movimento.intplancamento||')';
               btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                         ,pr_ind_tipo_log => 2 
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' >>> '
                                                            || vr_dscritic );

               RAISE vr_exc_saida;
            ELSE
               CLOSE cr_crapass;
            END IF;

            OPEN cr_crapmfx (pr_cdcooper => rw_consig_movimento.cdcooper
                            ,pr_dtmvtolt => vr_dtmvtolt
                            ,pr_tpmoefix => 2);
            FETCH cr_crapmfx INTO rw_crapmfx;
            IF cr_crapmfx%NOTFOUND THEN
               CLOSE cr_crapmfx;
               vr_cdcritic:= 140;
               vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               vr_dscritic:= vr_dscritic ||' da UFIR.';

               vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                rw_consig_movimento.nrctremp||'/'||
                                                rw_consig_movimento.nrparcela||'/'||
                                                rw_consig_movimento.intplancamento||')';
               btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                         ,pr_ind_tipo_log => 2 
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' >>> '
                                                            || vr_dscritic );
               RAISE vr_exc_saida;
            END IF;
            CLOSE cr_crapmfx;

            rw_vecto_parc.vr_existe:= 'N';
            OPEN cr_vecto_parc (pr_cdcooper => rw_consig_movimento.cdcooper,
                                pr_nrdconta => rw_consig_movimento.nrdconta,
                                pr_nrctremp => rw_consig_movimento.nrctremp,
                                pr_dtmvtolt => vr_dtmvtolt,
                                pr_dtmvtoan => vr_dtmvtoan);

            FETCH cr_vecto_parc INTO rw_vecto_parc;
            CLOSE cr_vecto_parc;
            vr_nrdolote:= 600013;
            vr_cdhistor:= null;
            vr_vlmovimento:= rw_consig_movimento.vlsaldo;
            IF rw_consig_movimento.intplancamento IN(2,3) THEN 
                                                               
                 
                 IF rw_consig_movimento.dsmotivo = 'PAGTOAVAL' THEN
                   vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1057 ELSE 1045 END;
                 ELSE
               vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1039 ELSE 1044 END;
                 END IF;

               vr_vlmovimento:= rw_consig_movimento.vlsaldo - NVL(rw_consig_movimento.vldesconto,0);
            ELSIF rw_consig_movimento.intplancamento = 4 THEN 
                 
                 IF rw_consig_movimento.dsmotivo = 'PAGTOAVAL' THEN 
                   vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1620 ELSE 1619 END;
                 ELSE
               vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1078 ELSE 1077 END;
                 END IF;

            ELSIF rw_consig_movimento.intplancamento = 5 THEN 
                 
                 IF rw_consig_movimento.dsmotivo = 'PAGTOAVAL' THEN 
                   vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1618 ELSE 1540 END;
                 ELSE
               vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1076 ELSE 1047 END;
                 END IF;

            ELSIF rw_consig_movimento.intplancamento = 6 THEN 
               vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 2312 ELSE 2311 END;

            ELSIF rw_consig_movimento.intplancamento = 7 THEN 
                vr_cdhistor := CASE vr_floperac WHEN TRUE THEN 1049 ELSE 1048 END;

            ELSIF rw_consig_movimento.intplancamento IN (11,12) THEN 
                   
                   IF rw_consig_movimento.dsmotivo = 'ESTORNOAVAL' THEN 
                     vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1057 ELSE 1045 END;
                   ELSE
                     vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1039 ELSE 1044 END;
                   END IF;
                   
                vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                        pr_cdhistor => vr_cdhistor_es);
                  
                vr_vlmovimento:= rw_consig_movimento.vlsaldo - NVL(rw_consig_movimento.vlestdesconto,0); 

            ELSIF rw_consig_movimento.intplancamento = 13 THEN 
                  
                 IF rw_consig_movimento.dsmotivo = 'ESTORNOAVAL' THEN 
                   vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1620 ELSE 1619 END;
                 ELSE
                    vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1078 ELSE 1077 END;
                 END IF;
                  
                vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                       pr_cdhistor => vr_cdhistor_es);

            ELSIF rw_consig_movimento.intplancamento = 14 THEN 
                  
                 IF rw_consig_movimento.dsmotivo = 'ESTORNOAVAL' THEN 
                   vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1618 ELSE 1540 END;
                 ELSE
                    vr_cdhistor_es := CASE vr_floperac WHEN TRUE THEN 1076 ELSE 1047 END;
                 END IF;
                  
                vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                       pr_cdhistor => vr_cdhistor_es);

            ELSIF rw_consig_movimento.intplancamento = 15 THEN 
                vr_cdhistor:= fn_busca_hist_estorno (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                     pr_cdhistor =>  CASE vr_floperac WHEN TRUE THEN 2312 ELSE 2311 END);

            ELSIF rw_consig_movimento.intplancamento IN (1,8,9,10,16,17,18) THEN
                 vr_cdhistor:= NULL;
            END IF;

            IF (rw_consig_movimento.intplancamento = 2 OR 
                rw_vecto_parc.vr_existe = 'S' OR 
                trunc(vr_dtmvtolt,'mm') <> trunc(vr_dtmvtopr,'mm')) THEN
                vr_cdhistorrem := CASE vr_floperac WHEN TRUE THEN 1038 ELSE 1037 END;
                vr_jurosrem:= 0;
                FOR rw_juros_rem IN cr_juros_rem (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                  pr_nrdconta => rw_consig_movimento.nrdconta,
                                                  pr_nrctremp => rw_consig_movimento.nrctremp,
                                                  pr_nrparepr => 0,
                                                  pr_dtmovimento => vr_dtmvtolt)
                LOOP
                  vr_jurosrem:= rw_juros_rem.vljurosrem;
                END LOOP;

                IF vr_jurosrem > 0 THEN
                  empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_consig_movimento.cdcooper 
                                                  ,pr_dtmvtolt => vr_dtmvtolt_lanc 
                                                  ,pr_cdagenci => rw_crapass.cdagenci 
                                                  ,pr_cdbccxlt => 100 
                                                  ,pr_cdoperad => vr_cdoperad 
                                                  ,pr_cdpactra => rw_crapass.cdagenci 
                                                  ,pr_tplotmov => 5 
                                                  ,pr_nrdolote => vr_nrdolote 
                                                  ,pr_nrdconta => rw_consig_movimento.nrdconta
                                                  ,pr_cdhistor => vr_cdhistorrem 
                                                  ,pr_nrctremp => rw_consig_movimento.nrctremp 
                                                  ,pr_vllanmto => vr_jurosrem 
                                                  ,pr_dtpagemp => vr_dtmvtolt_lanc
                                                  ,pr_txjurepr => rw_consig_movimento.txjuremp 
                                                  ,pr_vlpreemp => rw_consig_movimento.vlpreemp 
                                                  ,pr_nrsequni => 0 
                                                  ,pr_nrparepr => 0 
                                                  ,pr_flgincre => TRUE 
                                                  ,pr_flgcredi => TRUE 
                                                  ,pr_nrseqava => 0 
                                                  ,pr_cdorigem => 7 
                                                  ,pr_cdcritic => vr_cdcritic 
                                                  ,pr_dscritic => vr_dscritic); 
                    IF vr_cdcritic IS NOT NULL OR
                       vr_dscritic IS NOT NULL THEN
                       vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                        rw_consig_movimento.nrctremp||'/'||
                                                        rw_consig_movimento.nrparcela||'/'||
                                                        rw_consig_movimento.intplancamento||')';
                       btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                                 ,pr_ind_tipo_log => 2 
                                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                     || vr_cdprogra || ' >>> '
                                                                      || vr_dscritic );
                       RAISE vr_exc_saida;
                    END IF;

                    BEGIN
                      vr_contrato_liquidado := rw_consig_movimento.inliquid;
                      FOR rw_contrato_liquidado IN cr_contrato_liquidado (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                  pr_nrdconta => rw_consig_movimento.nrdconta,
                                                  pr_nrctremp => rw_consig_movimento.nrctremp)
                      LOOP
                        vr_contrato_liquidado := rw_contrato_liquidado.inliquid;
                      END LOOP;
                      
                      vr_maior_dtmvtolt := rw_consig_movimento.dtrefjur;
                      FOR rw_maior_dtmvtolt_craplem IN cr_maior_dtmvtolt_craplem (pr_cdcooper => rw_consig_movimento.cdcooper,
                                                  pr_nrdconta => rw_consig_movimento.nrdconta,
                                                  pr_nrctremp => rw_consig_movimento.nrctremp)
                      LOOP
                        vr_maior_dtmvtolt := rw_maior_dtmvtolt_craplem.dtmvtolt;
                      END LOOP;
                      
                      UPDATE crapepr epr
                         SET epr.dtrefjur = vr_maior_dtmvtolt,
                             epr.inliquid = vr_contrato_liquidado                         
                       WHERE epr.cdcooper = rw_consig_movimento.cdcooper
                         AND epr.nrdconta = rw_consig_movimento.nrdconta
                         AND epr.nrctremp = rw_consig_movimento.nrctremp;

                    EXCEPTION
                      WHEN OTHERS THEN
                        cecred.pc_internal_exception;
                        vr_cdcritic:= 0;
                        vr_dscritic:= 'Erro ao atualizar tabela CRAPEPR - '||SQLERRM;
                        vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                         rw_consig_movimento.nrctremp||'/'||
                                                         rw_consig_movimento.nrparcela||'/'||
                                                         rw_consig_movimento.intplancamento||')';
                        btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                                  ,pr_ind_tipo_log => 2 
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                     || vr_cdprogra || ' >>> '
                                                                     || vr_dscritic );
                        RAISE vr_exc_saida;
                    END;

                    BEGIN
                      UPDATE tbepr_consig_movimento_tmp a
                         SET a.instatusproces = 'P'
                       WHERE a.cdcooper  = rw_consig_movimento.cdcooper
                         AND a.nrdconta  = rw_consig_movimento.nrdconta
                         AND a.nrctremp  = rw_consig_movimento.nrctremp
                         AND a.dtmovimento <= vr_dtmvtolt
                         AND a.nrparcela = 0
                         AND a.intplancamento = 10 
                         AND a.instatusproces is null;
                   EXCEPTION
                     WHEN OTHERS THEN
                       cecred.pc_internal_exception;
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao atualizar tbepr_consig_movimento_tmp: '||SQLERRM;
                        vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                         rw_consig_movimento.nrctremp||'/'||
                                                         rw_consig_movimento.nrparcela||'/'||
                                                         rw_consig_movimento.intplancamento||')';
                        btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                                  ,pr_ind_tipo_log => 2 
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                      || vr_cdprogra || ' >>> '
                                                                      || vr_dscritic );
                        RAISE vr_exc_saida;
                   END;

                    OPEN cr_crapcot (pr_cdcooper => rw_consig_movimento.cdcooper
                                    ,pr_nrdconta => rw_consig_movimento.nrdconta);
                     FETCH cr_crapcot INTO rw_crapcot;
                     IF cr_crapcot%NOTFOUND THEN
                      CLOSE cr_crapcot;
                       vr_cdcritic:= 169;
                       vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                       vr_dscritic:= vr_dscritic||' - CONTA = '||gene0002.fn_mask(rw_consig_movimento.nrdconta,'zzzz.zz9.9')||
                                                  ' ('||rw_consig_movimento.nrdconta||'/'||
                                                        rw_consig_movimento.nrctremp||'/'||
                                                        rw_consig_movimento.nrparcela||'/'||
                                                        rw_consig_movimento.intplancamento||')';
                       btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                                 ,pr_ind_tipo_log => 2 
                                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                     || vr_cdprogra || ' >>> '
                                                                     || vr_dscritic );

                       RAISE vr_exc_saida;
                     ELSE
                       CLOSE cr_crapcot;
                       BEGIN
                         UPDATE crapcot cot
                            SET cot.qtjurmfx = nvl(cot.qtjurmfx,0) +
                                               ROUND(vr_jurosrem / rw_crapmfx.vlmoefix,4)
                          WHERE cot.rowid = rw_crapcot.rowid;
                       EXCEPTION
                         WHEN OTHERS THEN
                           cecred.pc_internal_exception;
                           vr_cdcritic:= 0;
                           vr_dscritic:= 'Erro ao atualizar tabela crapcot. '||SQLERRM;

                           vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                            rw_consig_movimento.nrctremp||'/'||
                                                            rw_consig_movimento.nrparcela||'/'||
                                                            rw_consig_movimento.intplancamento||')';
                           btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                                     ,pr_ind_tipo_log => 2 
                                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                        || vr_cdprogra || ' >>> '
                                                                        || vr_dscritic );
                           RAISE vr_exc_saida;
                       END;
                     END IF;
                   END IF;      
              END IF;

              IF rw_consig_movimento.inprejuz = 1 AND vr_cdhistor IS NOT NULL THEN
                 vr_cdhistor := NULL;
                 BEGIN
                    UPDATE tbepr_consig_movimento_tmp a
                       SET a.instatusproces = 'P'
                     WHERE a.cdcooper  = rw_consig_movimento.cdcooper
                       AND a.nrdconta  = rw_consig_movimento.nrdconta
                       AND a.nrctremp  = rw_consig_movimento.nrctremp
                       AND a.nrparcela = rw_consig_movimento.nrparcela
                       AND decode(a.intplancamento,3,2,
                                   decode(a.intplancamento,12,11,a.intplancamento))  = rw_consig_movimento.intplancamento
                       AND a.dtmovimento = rw_consig_movimento.dtmovimento;
                 EXCEPTION
                 WHEN OTHERS THEN
                   cecred.pc_internal_exception;
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar tbepr_consig_movimento_tmp: '||SQLERRM;
                    vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                     rw_consig_movimento.nrctremp||'/'||
                                                     rw_consig_movimento.nrparcela||'/'||
                                                     rw_consig_movimento.intplancamento||')';
                    btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                              ,pr_ind_tipo_log => 2 
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                  || vr_cdprogra || ' >>> '
                                                                  || vr_dscritic );
                    RAISE vr_exc_saida;
                 END;
            END IF;

            IF vr_cdhistor IS NOT NULL THEN
               vr_index_inorigem:= lpad(rw_consig_movimento.cdcooper, 10, '0') ||
                                   lpad(rw_consig_movimento.nrdconta, 10, '0') ||
                                   lpad(rw_consig_movimento.nrctremp, 10, '0') ||
                                   lpad(rw_consig_movimento.nrparcela,10, '0');

               IF rw_consig_movimento.intplancamento IN(2,3,11,12) THEN 
                  OPEN cr_consignado_pagto(pr_cdcooper => rw_consig_movimento.cdcooper,
                                           pr_nrdconta => rw_consig_movimento.nrdconta,
                                           pr_nrctremp => rw_consig_movimento.nrctremp,
                                           pr_nrparepr => rw_consig_movimento.nrparcela,
                                           pr_dtmvtolt => rw_consig_movimento.dtmovimento,
                                           pr_dsmotivo => rw_consig_movimento.dsmotivo,
                                           pr_idintegracao => rw_consig_movimento.idintegracao
                                           );

                  FETCH cr_consignado_pagto
                   INTO rw_consignado_pagto;
                  IF cr_consignado_pagto%NOTFOUND THEN
                     vr_cdorigem:= 20; 
                     CLOSE cr_consignado_pagto;
                     IF rw_consig_movimento.intplancamento IN(2,3) THEN
                        IF rw_consig_movimento.indautrepassecc = 1 THEN 
                            vr_cdhistor:=  3026; 
                         ELSE
                            vr_cdhistor:=  3027; 
                         END IF;
                     END IF;
                  ELSE
                     vr_cdorigem:= 5; 
                     CLOSE cr_consignado_pagto;
                  END IF;
               ELSE
                   vr_cdorigem:= 5; 
               END IF;
               vr_tab_inorigem(vr_index_inorigem).inorigem := vr_cdorigem;

               empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_consig_movimento.cdcooper 
                                              ,pr_dtmvtolt => vr_dtmvtolt_lanc 
                                              ,pr_cdagenci => rw_crapass.cdagenci 
                                              ,pr_cdbccxlt => 100 
                                              ,pr_cdoperad => vr_cdoperad 
                                              ,pr_cdpactra => rw_crapass.cdagenci 
                                              ,pr_tplotmov => 5 
                                              ,pr_nrdolote => vr_nrdolote 
                                              ,pr_nrdconta => rw_consig_movimento.nrdconta 
                                              ,pr_cdhistor => vr_cdhistor 
                                              ,pr_nrctremp => rw_consig_movimento.nrctremp 
                                              ,pr_vllanmto => vr_vlmovimento 
                                              ,pr_dtpagemp => vr_dtmvtolt_lanc 
                                              ,pr_txjurepr => rw_consig_movimento.txjuremp 
                                              ,pr_vlpreemp => rw_consig_movimento.vlpreemp 
                                              ,pr_nrsequni => rw_consig_movimento.nrparcela
                                              ,pr_nrparepr => rw_consig_movimento.nrparcela
                                              ,pr_flgincre => TRUE 
                                              ,pr_flgcredi => TRUE 
                                              ,pr_nrseqava => 0 
                                              ,pr_cdorigem => vr_cdorigem
                                              ,pr_cdcritic => vr_cdcritic 
                                              ,pr_dscritic => vr_dscritic); 
               IF vr_cdcritic IS NOT NULL OR
                  vr_dscritic IS NOT NULL THEN
                  vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                   rw_consig_movimento.nrctremp||'/'||
                                                   rw_consig_movimento.nrparcela||'/'||
                                                   rw_consig_movimento.intplancamento||')';
                  btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                            ,pr_ind_tipo_log => 2 
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' >>> '
                                                               || vr_dscritic );
                  RAISE vr_exc_saida;
               END IF;

               BEGIN
                  UPDATE tbepr_consig_movimento_tmp a
                     SET a.instatusproces = 'P'
                   WHERE a.cdcooper  = rw_consig_movimento.cdcooper
                     AND a.nrdconta  = rw_consig_movimento.nrdconta
                     AND a.nrctremp  = rw_consig_movimento.nrctremp
                     AND a.nrparcela = rw_consig_movimento.nrparcela
                     AND decode(a.intplancamento,3,2,
                                 decode(a.intplancamento,12,11,a.intplancamento))  = rw_consig_movimento.intplancamento
                     AND a.dtmovimento = rw_consig_movimento.dtmovimento;
               EXCEPTION
                 WHEN OTHERS THEN
                   cecred.pc_internal_exception;
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar tbepr_consig_movimento_tmp: '||SQLERRM;
                    vr_dscritic:= vr_dscritic||' ('||rw_consig_movimento.nrdconta||'/'||
                                                     rw_consig_movimento.nrctremp||'/'||
                                                     rw_consig_movimento.nrparcela||'/'||
                                                     rw_consig_movimento.intplancamento||')';
                    btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                              ,pr_ind_tipo_log => 2 
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                  || vr_cdprogra || ' >>> '
                                                                  || vr_dscritic );
                    RAISE vr_exc_saida;
               END;
             END IF;
        END LOOP;
       
      END LOOP;
   END IF; 

   commit;
   
   Dbms_Output.put_line('SUCESSO.');
   EXCEPTION
    WHEN vr_exc_saida THEN
      ROLLBACK;
      Dbms_Output.put_line(TO_CHAR(NVL(vr_cdcritic,0)) || ' - ' || vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                   ,pr_ind_tipo_log => 2
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' >>> '
                                                     || vr_dscritic );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK;
      Dbms_Output.put_line(TO_CHAR(NVL(vr_cdcritic,0)) || ' - ' || vr_dscritic);
      
      cecred.pc_internal_exception(pr_cdcooper => rw_crapcop.cdcooper,
                                   pr_compleme => 'pr_cdcooper: ' || rw_crapcop.cdcooper ||
                                                 ' pr_cdagenci: ' || 0 ||
                                                 ' pr_nmdatela: ' || vr_cdprogra ||
                                                 ' pr_idparale: ' || 0);
  END;
END; 
