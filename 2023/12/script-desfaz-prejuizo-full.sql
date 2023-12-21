DECLARE

  vr_vlsdprej      NUMBER;
  vr_vlsdprej_orig NUMBER;
  vr_exc_saida EXCEPTION;
  rw_crapdat        btch0001.cr_crapdat%ROWTYPE;
  vr_des_reto       VARCHAR(3);
  vr_tab_erro       gene0001.typ_tab_erro;
  vr_tab_lanctos    prej0004.typ_tab_lanctos;
  vr_cdcritic       crapcri.cdcritic%TYPE;
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_vlslddia_preju NUMBER;

  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                    
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  PROCEDURE pc_busca_vlrs_prejuz_cc(pr_cdcooper      IN crapass.cdcooper%TYPE
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE
                                   ,pr_vlsdprej      OUT NUMBER
                                   ,pr_vlsdprej_orig OUT NUMBER) IS
  
    CURSOR cr_busca_vlrs_prejuz_cc(pr_cdcooper crapass.cdcooper%TYPE
                                  ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT (nvl(prej.vlsdprej, 0) + nvl(prej.vljur60_ctneg, 0) +
              nvl(prej.vljur60_lcred, 0) + nvl(prej.vljuprej, 0)) vlsdprej_ori,
             nvl(sld.vliofmes, 0) vliofmes
        FROM tbcc_prejuizo prej
        LEFT JOIN crapsld sld
          ON sld.nrdconta = prej.nrdconta
         AND sld.cdcooper = prej.cdcooper
       WHERE prej.cdcooper = pr_cdcooper
         AND prej.nrdconta = pr_nrdconta
         AND prej.dtliquidacao IS NULL;
    rw_busca_vlrs_prejuz_cc cr_busca_vlrs_prejuz_cc%ROWTYPE;
  
    vr_vljupre_prov NUMBER := 0;
    vr_cdcritic     crapcri.cdcritic%TYPE;
    vr_dscritic     VARCHAR2(1000);
  
  BEGIN
  
    OPEN cr_busca_vlrs_prejuz_cc(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta);
    FETCH cr_busca_vlrs_prejuz_cc
      INTO rw_busca_vlrs_prejuz_cc;
    CLOSE cr_busca_vlrs_prejuz_cc;
  
    prej0003.pc_calc_juros_remun_prov(pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => pr_nrdconta,
                                      pr_vljuprov => vr_vljupre_prov,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
  
    pr_vlsdprej := nvl(rw_busca_vlrs_prejuz_cc.vlsdprej_ori, 0) +
                   nvl(rw_busca_vlrs_prejuz_cc.vliofmes, 0) +
                   nvl(vr_vljupre_prov, 0);
  
    pr_vlsdprej_orig := nvl(rw_busca_vlrs_prejuz_cc.vlsdprej_ori, 0);
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_vlsdprej      := 0;
      pr_vlsdprej_orig := 0;
    
  END pc_busca_vlrs_prejuz_cc;

  PROCEDURE pc_retorna_lancamentos_prej(pr_cdcooper       IN crapcop.cdcooper%TYPE
                                       ,pr_nrdconta       IN crapass.nrdconta%TYPE
                                       ,pr_dtiniper       IN DATE
                                       ,pr_dtfimper       IN DATE
                                       ,pr_vlslddia_preju OUT NUMBER
                                       ,pr_cdcritic       OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic       OUT VARCHAR2) IS
  
    CURSOR cr_lanc(pr_cdcooper IN crapass.cdcooper%TYPE
                  ,pr_nrdconta IN crapass.nrdconta%TYPE
                  ,pr_dtiniper IN DATE
                  ,pr_dtfimper IN DATE) IS
      SELECT t.idlancto_prejuizo, t.dtmvtolt, t.nrdocmto, t.cdhistor,
             t.dshistor, t.indebcre, abs(t.vllanmto) vllanmto,
             SUM(SUM(t.vllanmto)) over(ORDER BY idlancto_prejuizo rows BETWEEN unbounded preceding AND CURRENT ROW) vlsaldo,
             COUNT(1) over(PARTITION BY t.dtmvtolt) nrregtot,
             row_number() over(PARTITION BY t.dtmvtolt ORDER BY t.idlancto_prejuizo) nrregist
        FROM (SELECT lan.idlancto_prejuizo, lan.dtmvtolt, lan.nrdocmto,
                      his.cdhistor, his.dshistor, his.indebcre,
                      decode(his.indebcre,
                              'D',
                              lan.vllanmto * -1,
                              lan.vllanmto) vllanmto
                 FROM tbcc_prejuizo_lancamento lan, craphis his
                WHERE lan.cdcooper = his.cdcooper
                  AND lan.cdhistor = his.cdhistor
                  AND lan.cdcooper = pr_cdcooper
                  AND lan.nrdconta = pr_nrdconta
                  AND lan.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper) t
       GROUP BY t.idlancto_prejuizo, t.dtmvtolt, t.nrdocmto, t.cdhistor,
                t.dshistor, t.indebcre, t.vllanmto
       ORDER BY t.idlancto_prejuizo;
  
    vr_cdcritic NUMBER(3);
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
  
    rw_crapdat     btch0001.cr_crapdat%ROWTYPE;
    vr_tab_lanctos prej0004.typ_tab_lanctos;
    vr_idx         PLS_INTEGER;
    vr_dtmvtoan    DATE;
    vr_vlsldini    NUMBER;
  
  BEGIN
  
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
  
    vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                               pr_dtmvtolt => pr_dtiniper - 1,
                                               pr_tipo     => 'A');
  
    prej0003.pc_ret_saldo_dia_prej(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_dtmvtolt => vr_dtmvtoan,
                                   pr_vldsaldo => vr_vlsldini,
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic);
  
    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    vr_idx := vr_tab_lanctos.count + 1;
  
    vr_tab_lanctos(vr_idx).tpregistro := 'SI';
    vr_tab_lanctos(vr_idx).dsextrato := 'SALDO ANTERIOR';
    vr_tab_lanctos(vr_idx).dtmvtolt := vr_dtmvtoan;
    vr_tab_lanctos(vr_idx).cdhistor := NULL;
    vr_tab_lanctos(vr_idx).dshistor := NULL;
    vr_tab_lanctos(vr_idx).indebcre := NULL;
    vr_tab_lanctos(vr_idx).vllamnto := NULL;
    vr_tab_lanctos(vr_idx).vlslddia := vr_vlsldini;
  
    FOR rw_lanc IN cr_lanc(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                           pr_dtiniper => pr_dtiniper,
                           pr_dtfimper => pr_dtfimper) LOOP
      vr_idx := vr_tab_lanctos.count + 1;
    
      vr_tab_lanctos(vr_idx).tpregistro := 'L';
      vr_tab_lanctos(vr_idx).dsextrato := rw_lanc.dshistor;
      vr_tab_lanctos(vr_idx).dtmvtolt := rw_lanc.dtmvtolt;
      vr_tab_lanctos(vr_idx).nrdocmto := rw_lanc.nrdocmto;
      vr_tab_lanctos(vr_idx).cdhistor := rw_lanc.cdhistor;
      vr_tab_lanctos(vr_idx).dshistor := rw_lanc.dshistor;
      vr_tab_lanctos(vr_idx).indebcre := rw_lanc.indebcre;
      vr_tab_lanctos(vr_idx).vllamnto := rw_lanc.vllanmto;
    
      IF rw_lanc.nrregtot = rw_lanc.nrregist THEN
      
        vr_tab_lanctos(vr_idx).vlslddia := rw_lanc.vlsaldo + vr_vlsldini;
      
        vr_idx := vr_tab_lanctos.count + 1;
      
        vr_tab_lanctos(vr_idx).tpregistro := 'SD';
        vr_tab_lanctos(vr_idx).dsextrato := to_char(rw_lanc.dtmvtolt,
                                                    'DD/MM/RRRR');
        vr_tab_lanctos(vr_idx).dtmvtolt := rw_lanc.dtmvtolt;
        vr_tab_lanctos(vr_idx).cdhistor := NULL;
        vr_tab_lanctos(vr_idx).dshistor := NULL;
        vr_tab_lanctos(vr_idx).indebcre := NULL;
        vr_tab_lanctos(vr_idx).vllamnto := NULL;
        vr_tab_lanctos(vr_idx).vlslddia := rw_lanc.vlsaldo + vr_vlsldini;
      
      END IF;
    
    END LOOP;
  
    pr_vlslddia_preju := nvl(vr_tab_lanctos(vr_idx).vlslddia, 0);
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic, 0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
    
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao buscar lancamentos: ' || SQLERRM;
    
  END pc_retorna_lancamentos_prej;

  PROCEDURE pc_paga_prejuz_cc(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapcpa.nrdconta%TYPE
                             ,pr_vlrpagto IN NUMBER
                             ,pr_vlrabono IN NUMBER
                             ,pr_cdcritic OUT PLS_INTEGER
                             ,pr_dscritic OUT VARCHAR2) IS
  
    CURSOR cr_prejuizo IS
      SELECT prj.vlsdprej, prj.vljuprej, prj.vljur60_ctneg,
             prj.vljur60_lcred, prj.vlsldlib, sld.vliofmes
        FROM tbcc_prejuizo prj, crapsld sld
       WHERE prj.cdcooper = pr_cdcooper
         AND prj.nrdconta = pr_nrdconta
         AND prj.dtliquidacao IS NULL
         AND sld.cdcooper = prj.cdcooper
         AND sld.nrdconta = prj.nrdconta;
    rw_prejuizo cr_prejuizo%ROWTYPE;
  
    vr_exc_erro EXCEPTION;
  
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(1000);
  
    vr_slddev      NUMBER;
    vr_juprej_prov NUMBER;
  
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  BEGIN
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    OPEN cr_prejuizo;
    FETCH cr_prejuizo
      INTO rw_prejuizo;
    CLOSE cr_prejuizo;
  
    prej0003.pc_calc_juros_remun_prov(pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => pr_nrdconta,
                                      pr_vljuprov => vr_juprej_prov,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
  
    vr_slddev := rw_prejuizo.vlsdprej + rw_prejuizo.vljuprej +
                 rw_prejuizo.vljur60_ctneg + rw_prejuizo.vljur60_lcred +
                 rw_prejuizo.vliofmes + vr_juprej_prov;
  
    IF (pr_vlrpagto + nvl(pr_vlrabono, 0)) > vr_slddev THEN
      vr_dscritic := 'O valor total informado para pagamento é maior que o saldo devedor.';
      RAISE vr_exc_erro;
    END IF;
  
    IF pr_vlrpagto >
       prej0003.fn_sld_cta_prj(pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => pr_nrdconta) THEN
      vr_dscritic := 'O valor informado para pagamento é maior que o saldo disponível.';
      RAISE vr_exc_erro;
    END IF;
  
    IF rw_prejuizo.vliofmes > 0 AND rw_prejuizo.vliofmes > pr_vlrpagto AND
       pr_vlrabono > 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'IOF não pode ser abonado, necessário realizar pagamento no mínimo de ' ||
                     to_char(rw_prejuizo.vliofmes,
                             '9G999G990D00',
                             'nls_numeric_characters='',.''');
      RAISE vr_exc_erro;
    END IF;
  
    UPDATE tbcc_prejuizo
       SET vlsldlib = vlsldlib + pr_vlrpagto
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND dtliquidacao IS NULL;
  
    prej0003.pc_pagar_prejuizo_cc(pr_cdcooper => pr_cdcooper,
                                  pr_nrdconta => pr_nrdconta,
                                  pr_vlrpagto => pr_vlrpagto,
                                  pr_vlrabono => pr_vlrabono,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
  
    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    IF pr_vlrpagto > 0 THEN
      prej0003.pc_gera_transf_cta_prj(pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => pr_nrdconta,
                                      pr_cdoperad => '1',
                                      pr_vllanmto => pr_vlrpagto,
                                      pr_atsldlib => 0,
                                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
    
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possível efetuar o pagamento do prejuízo. ERRO -> ' ||
                     SQLERRM;
    
  END pc_paga_prejuz_cc;

  PROCEDURE pc_reabrir_conta_corrente(pr_cdcooper IN NUMBER
                                     ,pr_nrdconta IN NUMBER
                                     ,pr_dtprejuz IN DATE
                                     ,pr_dscritic OUT VARCHAR2) IS
    vr_erro EXCEPTION;
  
  BEGIN
    BEGIN
      UPDATE crapcrm
         SET crapcrm.cdsitcar = 2, crapcrm.dtcancel = NULL,
             crapcrm.dttransa = pr_dtprejuz
       WHERE crapcrm.cdcooper = pr_cdcooper
         AND crapcrm.nrdconta = pr_nrdconta
         AND crapcrm.cdsitcar = 4;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao desbloquear cartao magnetico: ' || SQLERRM;
        RAISE vr_erro;
      
    END;
  
    BEGIN
      UPDATE crapsnh
         SET crapsnh.cdsitsnh = 1, crapsnh.dtblutsh = NULL,
             crapsnh.dtaltsnh = pr_dtprejuz
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.cdsitsnh = 2
         AND crapsnh.tpdsenha = 1
         AND crapsnh.idseqttl = 1;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao reativar senha internet: ' || SQLERRM;
        RAISE vr_erro;
      
    END;
  
  EXCEPTION
    WHEN vr_erro THEN
      pr_dscritic := 'erro na rotina de bloqueio de contas';
    
  END pc_reabrir_conta_corrente;

  PROCEDURE pc_liquida_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT VARCHAR2) IS
  
    CURSOR cr_conta_liquida(pr_cdooper IN tbcc_prejuizo.cdcooper%TYPE) IS
      SELECT tbprj.nrdconta, tbprj.cdcooper, tbprj.cdsitdct_original,
             tbprj.rowid
        FROM tbcc_prejuizo tbprj
       WHERE tbprj.cdcooper = pr_cdcooper
         AND tbprj.nrdconta = pr_nrdconta
         AND tbprj.dtliquidacao IS NULL
         AND (tbprj.vlsdprej + tbprj.vljuprej + tbprj.vljur60_ctneg +
             tbprj.vljur60_lcred) = 0;
  
    CURSOR cr_conta_nprej_sitprej IS
      SELECT ass.nrdconta, ass.cdcooper
        FROM crapass ass
       WHERE ass.inprejuz = 0
         AND ass.cdsitdct = 2
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_cr_conta_nprej_sitprej cr_conta_nprej_sitprej%ROWTYPE;
  
    CURSOR cr_prej_recente(pr_cdcooper IN crapass.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT cdsitdct_original
        FROM (SELECT DISTINCT tbprj.dtinclusao, tbprj.cdsitdct_original
                 FROM tbcc_prejuizo tbprj
                WHERE tbprj.cdcooper = pr_cdcooper
                  AND tbprj.nrdconta = pr_nrdconta
                ORDER BY dtinclusao DESC)
       WHERE rownum = 1;
    rw_prej_recente cr_prej_recente%ROWTYPE;
  
    vr_cdcritic NUMBER(3);
    vr_dscritic VARCHAR2(1000);
    vr_exc_saida EXCEPTION;
  
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    FUNCTION fn_verifica_preju_ativo(pr_cdcooper craplcm.cdcooper%TYPE
                                    ,pr_nrdconta craplcm.nrdconta%TYPE
                                    ,pr_tipverif INTEGER DEFAULT 2)
      RETURN BOOLEAN AS
      vr_prejuizo_ativo BOOLEAN;
    
      CURSOR cr_ass_cpfcnpj(pr_tipverif IN INTEGER) IS
        SELECT ass.nrdconta, ass.inprejuz
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND pr_tipverif = 1
           AND ass.nrcpfcnpj_base =
               (SELECT a.nrcpfcnpj_base
                  FROM crapass a
                 WHERE a.cdcooper = pr_cdcooper
                   AND a.nrdconta = pr_nrdconta)
        UNION
        SELECT ass.nrdconta, ass.inprejuz
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND pr_tipverif = 2
           AND ass.nrdconta = pr_nrdconta;
      rw_ass_cpfcnpj cr_ass_cpfcnpj%ROWTYPE;
      CURSOR cr_preju_empr(pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT 1
          FROM crapepr e
         WHERE e.cdcooper = pr_cdcooper
           AND e.nrdconta = pr_nrdconta
           AND e.inprejuz = 1
           AND e.dtliqprj IS NULL
           AND e.vlsdprej > 0;
    
      CURSOR cr_preju_dsctit(pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT 1
          FROM crapbdt b
         WHERE b.cdcooper = pr_cdcooper
           AND b.nrdconta = pr_nrdconta
           AND b.inprejuz = 1
           AND b.dtliqprj IS NULL;
    
      vr_inprejuz        crapass.inprejuz%TYPE;
      vr_tipoverificacao INTEGER;
    BEGIN
      vr_prejuizo_ativo  := FALSE;
      vr_tipoverificacao := pr_tipverif;
    
      IF pr_tipverif NOT IN (1, 2) THEN
        vr_tipoverificacao := 2;
      END IF;
    
      FOR rw_ass_cpfcnpj IN cr_ass_cpfcnpj(vr_tipoverificacao) LOOP
      
        IF rw_ass_cpfcnpj.inprejuz = 1 THEN
          RETURN TRUE;
        END IF;
      
        OPEN cr_preju_empr(pr_nrdconta => rw_ass_cpfcnpj.nrdconta);
        FETCH cr_preju_empr
          INTO vr_inprejuz;
        CLOSE cr_preju_empr;
        IF vr_inprejuz = 1 THEN
          RETURN TRUE;
        END IF;
      
        OPEN cr_preju_dsctit(pr_nrdconta => rw_ass_cpfcnpj.nrdconta);
        FETCH cr_preju_dsctit
          INTO vr_inprejuz;
        CLOSE cr_preju_dsctit;
        IF vr_inprejuz = 1 THEN
          RETURN TRUE;
        END IF;
      
      END LOOP;
    
      RETURN vr_prejuizo_ativo;
    END fn_verifica_preju_ativo;
  
  BEGIN
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    FOR rw_cr_conta_nprej_sitprej IN cr_conta_nprej_sitprej LOOP
      BEGIN
        IF NOT
            fn_verifica_preju_ativo(pr_cdcooper => rw_cr_conta_nprej_sitprej.cdcooper,
                                    pr_nrdconta => rw_cr_conta_nprej_sitprej.nrdconta) THEN
          BEGIN
            OPEN cr_prej_recente(pr_cdcooper => rw_cr_conta_nprej_sitprej.cdcooper,
                                 pr_nrdconta => rw_cr_conta_nprej_sitprej.nrdconta);
            FETCH cr_prej_recente
              INTO rw_prej_recente;
          
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
          vr_cdcritic := 99999;
          vr_dscritic := 'Erro ao alterar a situação da conta - CRAPASS. ' ||
                         SQLERRM;
          RAISE vr_exc_saida;
      END;
    END LOOP;
  
    FOR rw_conta_liquida IN cr_conta_liquida(pr_cdcooper) LOOP
      BEGIN
        UPDATE crapass a
           SET a.inprejuz = 0
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = rw_conta_liquida.nrdconta;
      
        IF NOT
            fn_verifica_preju_ativo(pr_cdcooper => rw_conta_liquida.cdcooper,
                                    pr_nrdconta => rw_conta_liquida.nrdconta) THEN
          UPDATE crapass a
             SET a.cdsitdct = rw_conta_liquida.cdsitdct_original
           WHERE a.cdcooper = pr_cdcooper
             AND a.nrdconta = rw_conta_liquida.nrdconta;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 99999;
          vr_dscritic := 'Erro ao alterar a situação da conta - CRAPASS. ' ||
                         SQLERRM;
          RAISE vr_exc_saida;
      END;
    
      BEGIN
        UPDATE tbcc_prejuizo tbprj
           SET tbprj.vlsldlib = 0, tbprj.dtliquidacao = rw_crapdat.dtmvtolt
         WHERE tbprj.cdcooper = pr_cdcooper
           AND tbprj.rowid = rw_conta_liquida.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 99999;
          vr_dscritic := 'Erro ao atualizar a tabela TBCC_PREJUIZO. ' ||
                         SQLERRM;
          RAISE vr_exc_saida;
      END;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper,
                                   pr_compleme => 'PREJ0003.pc_liquida_prejuizo_cc: ' ||
                                                  SQLERRM);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic || SQLERRM;
    
  END pc_liquida_prejuizo_cc;

BEGIN

  FOR i IN (SELECT cdcooper, nrdconta
              FROM crapass
             WHERE progress_recid IN (160693,
                                      174505,
                                      580932,
                                      646241,
                                      743089,
                                      843321,
                                      870949,
                                      1054354,
                                      1081910,
                                      1145460,
                                      1158472,
                                      1237228,
                                      1239438,
                                      1258245,
                                      1277241,
                                      1310443,
                                      1409462,
                                      1520567,
                                      1565825,
                                      1575584,
                                      1609786,
                                      1647145,
                                      1682777,
                                      1855756,
                                      498720,
                                      657721,
                                      646713,
                                      139312,
                                      175167,
                                      259805,
                                      269857,
                                      303632,
                                      309178,
                                      552981,
                                      595140,
                                      643064,
                                      753534,
                                      793797,
                                      885757,
                                      963949,
                                      1006957,
                                      1146757,
                                      1308877,
                                      1319946,
                                      1334005,
                                      1358233,
                                      1359891,
                                      1418204,
                                      1420106,
                                      1436307,
                                      1464572,
                                      1478552,
                                      1481198,
                                      1499220,
                                      1530941,
                                      1543180,
                                      1584886,
                                      1679386,
                                      1682224,
                                      1710281,
                                      949896,
                                      971093,
                                      895519,
                                      1146049,
                                      1765956,
                                      745094,
                                      1183358,
                                      1214415,
                                      1685458,
                                      521885,
                                      173720,
                                      710452,
                                      253482,
                                      307685,
                                      316870,
                                      356240,
                                      724468,
                                      677269,
                                      1074706,
                                      1173840,
                                      1354510,
                                      1356657,
                                      1362182,
                                      1371020,
                                      1373060,
                                      1429465,
                                      1447329,
                                      1491525,
                                      1497007,
                                      1565721,
                                      1577380,
                                      1649195,
                                      1740823,
                                      1311773,
                                      1521320,
                                      1183186,
                                      1647195,
                                      1664940,
                                      284423,
                                      342895,
                                      650144,
                                      682506,
                                      781671,
                                      792458,
                                      1065172,
                                      1162216,
                                      1194344,
                                      1218112,
                                      1258336,
                                      1268003,
                                      1268508,
                                      1335308,
                                      1555113,
                                      1555532,
                                      1618591,
                                      1708120,
                                      1733740,
                                      1757366,
                                      1821869,
                                      697828,
                                      1824427,
                                      510314,
                                      1038668,
                                      1619170,
                                      114372,
                                      170654,
                                      235905,
                                      323293,
                                      605506,
                                      962234,
                                      969943,
                                      978666,
                                      1119970,
                                      1150857,
                                      1161525,
                                      1206550,
                                      1211555,
                                      1251786,
                                      1277393,
                                      1307620,
                                      1369471,
                                      1418565,
                                      1425994,
                                      1450268,
                                      1526451,
                                      1528380,
                                      1537699,
                                      1546551,
                                      1610457,
                                      1684159,
                                      1654071,
                                      856764,
                                      1195840,
                                      207323,
                                      700626,
                                      717319,
                                      592605,
                                      822964,
                                      914913,
                                      1096126,
                                      1180120,
                                      1256302,
                                      1288975,
                                      1323212,
                                      1327340,
                                      1341316,
                                      1393946,
                                      1447616,
                                      1162533,
                                      914697,
                                      504119,
                                      1269713,
                                      1786117,
                                      57467,
                                      132091,
                                      242949,
                                      262901,
                                      579423,
                                      613881,
                                      727241,
                                      727355,
                                      755638,
                                      877952,
                                      953277,
                                      970096,
                                      994768,
                                      1050543,
                                      1074842,
                                      1099692,
                                      1118208,
                                      1159560,
                                      1169184,
                                      1172324,
                                      1214323,
                                      1218906,
                                      1258271,
                                      1311263,
                                      1349410,
                                      1384808,
                                      1535638,
                                      1611355,
                                      1703148,
                                      1738841,
                                      1748826,
                                      371507,
                                      622842,
                                      1273538,
                                      259747,
                                      276878,
                                      340906,
                                      593389,
                                      580913,
                                      607345,
                                      757384,
                                      914613,
                                      915869,
                                      942781,
                                      944764,
                                      978313,
                                      1119580,
                                      1211400,
                                      1255197,
                                      1270565,
                                      1307192,
                                      1339205,
                                      1340792,
                                      1363862,
                                      1377612,
                                      1396152,
                                      1458968,
                                      1504458,
                                      1517172,
                                      1662878,
                                      1331302,
                                      799369,
                                      1737817,
                                      1436264,
                                      1106565,
                                      1164588,
                                      1324771,
                                      1609927)) LOOP
  
    OPEN btch0001.cr_crapdat(i.cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    OPEN cr_crapass(pr_cdcooper => i.cdcooper, pr_nrdconta => i.nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;
  
    pc_busca_vlrs_prejuz_cc(pr_cdcooper      => i.cdcooper,
                            pr_nrdconta      => i.nrdconta,
                            pr_vlsdprej      => vr_vlsdprej,
                            pr_vlsdprej_orig => vr_vlsdprej_orig);
  
    IF nvl(vr_vlsdprej, 0) > 0 THEN
      empr0001.pc_cria_lancamento_cc(pr_cdcooper => i.cdcooper,
                                     pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                     pr_cdagenci => rw_crapass.cdagenci,
                                     pr_cdbccxlt => 100,
                                     pr_cdoperad => 1,
                                     pr_cdpactra => rw_crapass.cdagenci,
                                     pr_nrdolote => 600031,
                                     pr_nrdconta => i.nrdconta,
                                     pr_cdhistor => 362,
                                     pr_vllanmto => vr_vlsdprej,
                                     pr_nrparepr => 0,
                                     pr_nrctremp => 0,
                                     pr_nrseqava => 0,
                                     pr_des_reto => vr_des_reto,
                                     pr_tab_erro => vr_tab_erro);
    
      IF vr_des_reto <> 'OK' THEN
        CONTINUE;
      END IF;
    
    END IF;
  
    pc_retorna_lancamentos_prej(pr_cdcooper       => i.cdcooper,
                                pr_nrdconta       => i.nrdconta,
                                pr_dtiniper       => rw_crapdat.dtmvtolt,
                                pr_dtfimper       => rw_crapdat.dtmvtolt,
                                pr_vlslddia_preju => vr_vlslddia_preju,
                                pr_cdcritic       => vr_cdcritic,
                                pr_dscritic       => vr_dscritic);
  
    IF (nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL) THEN
      CONTINUE;
    END IF;
  
    IF nvl(vr_vlslddia_preju, 0) >= vr_vlsdprej THEN
      pc_paga_prejuz_cc(pr_cdcooper => i.cdcooper,
                        pr_nrdconta => i.nrdconta,
                        pr_vlrpagto => vr_vlsdprej,
                        pr_vlrabono => 0,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);
    
      IF (nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL) THEN
        CONTINUE;
      END IF;
    
    END IF;
  
    pc_retorna_lancamentos_prej(pr_cdcooper       => i.cdcooper,
                                pr_nrdconta       => i.nrdconta,
                                pr_dtiniper       => rw_crapdat.dtmvtolt,
                                pr_dtfimper       => rw_crapdat.dtmvtolt,
                                pr_vlslddia_preju => vr_vlslddia_preju,
                                pr_cdcritic       => vr_cdcritic,
                                pr_dscritic       => vr_dscritic);
  
    IF (nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL) THEN
      CONTINUE;
    END IF;
  
    IF nvl(vr_vlslddia_preju, 0) > 0 THEN
    
      prej0003.pc_gera_transf_cta_prj(pr_cdcooper => i.cdcooper,
                                      pr_nrdconta => i.nrdconta,
                                      pr_cdoperad => 1,
                                      pr_vllanmto => vr_vlslddia_preju,
                                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);
    
      IF (nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL) THEN
        CONTINUE;
      END IF;
    
    END IF;
    pc_reabrir_conta_corrente(pr_cdcooper => i.cdcooper,
                              pr_nrdconta => i.nrdconta,
                              pr_dtprejuz => rw_crapdat.dtmvtolt,
                              pr_dscritic => vr_dscritic);
  
    IF (vr_dscritic IS NOT NULL) THEN
      CONTINUE;
    END IF;
  
    pc_liquida_prejuizo_cc(pr_cdcooper => i.cdcooper,
                           pr_nrdconta => i.nrdconta,
                           pr_cdcritic => vr_cdcritic,
                           pr_dscritic => vr_dscritic);
  
    IF (nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL) THEN
      CONTINUE;
    END IF;
  
    IF nvl(vr_vlsdprej_orig, 0) > 0 THEN
      empr0001.pc_cria_lancamento_cc(pr_cdcooper => i.cdcooper,
                                     pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                     pr_cdagenci => rw_crapass.cdagenci,
                                     pr_cdbccxlt => 100,
                                     pr_cdoperad => 1,
                                     pr_cdpactra => rw_crapass.cdagenci,
                                     pr_nrdolote => 600031,
                                     pr_nrdconta => i.nrdconta,
                                     pr_cdhistor => 360,
                                     pr_vllanmto => vr_vlsdprej_orig,
                                     pr_nrparepr => 0,
                                     pr_nrctremp => 0,
                                     pr_nrseqava => 0,
                                     pr_des_reto => vr_des_reto,
                                     pr_tab_erro => vr_tab_erro);
    
      IF vr_des_reto <> 'OK' THEN
        CONTINUE;
      END IF;
    
    END IF;
  
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
END;
