DECLARE
  CURSOR cr_his(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
               ,pr_cdhistor IN cecred.craphis.cdhistor%TYPE) IS
    SELECT t.cdhistor
          ,t.dshistor
          ,t.indebcre
      FROM cecred.craphis t
     WHERE t.cdcooper = pr_cdcooper
       AND t.cdhistor = pr_cdhistor;
  rw_his cr_his%ROWTYPE;

  CURSOR cr_sld_prj(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT *
      FROM (SELECT t.vlsdprej
                  ,t.idprejuizo
              FROM cecred.tbcc_prejuizo t
             WHERE t.cdcooper = pr_cdcooper
               AND t.nrdconta = pr_nrdconta
             ORDER BY t.idprejuizo DESC)
     WHERE ROWNUM = 1;
  rw_sld_prj cr_sld_prj%ROWTYPE;

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_progress IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta
      FROM cecred.crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress;
  rw_crapass cr_crapass%ROWTYPE;

  vr_indebcre    cecred.craphis.indebcre%TYPE;
  vr_found       BOOLEAN;
  vr_progress    cecred.crapass.progress_recid%TYPE;
  vr_cdcooper    cecred.crapcop.cdcooper%TYPE;
  vr_nrdconta    cecred.crapass.nrdconta%TYPE;
  vr_vllanmto    cecred.tbcc_prejuizo.vlsdprej%TYPE;
  vr_cdhistor    cecred.craphis.cdhistor%TYPE;
  vr_idlancto    cecred.tbcc_prejuizo_detalhe.idlancto%TYPE;
  vr_nrdocmto    INTEGER;
  vr_incrineg    INTEGER;
  vr_flgpreju    INTEGER;
  vr_flgconta    INTEGER;
  vr_tab_retorno cecred.LANC0001.typ_reg_retorno;
  rw_crapdat     cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_conta       cecred.GENE0002.typ_split;
  vr_reg_conta   cecred.GENE0002.typ_split;
  vr_cdcritic    NUMBER;
  vr_dscritic    VARCHAR2(1000);
  vr_des_erro    VARCHAR2(1000);
  vr_excerro EXCEPTION;

  PROCEDURE registrarVERLOG(pr_cdcooper IN cecred.crawepr.cdcooper%TYPE
                           ,pr_nrdconta IN cecred.crawepr.nrdconta%TYPE
                           ,pr_dstransa IN VARCHAR2
                           ,pr_dsCampo  IN VARCHAR
                           ,pr_antes    IN VARCHAR2
                           ,pr_depois   IN VARCHAR2) IS
    vr_dstransa       cecred.craplgm.dstransa%TYPE;
    vr_descitem       cecred.craplgi.nmdcampo%TYPE;
    vr_nrdrowid       ROWID;
    vr_risco_anterior VARCHAR2(10);
  BEGIN
    vr_dstransa := pr_dstransa;
  
    cecred.GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_dstransa => vr_dstransa,
                                pr_dscritic => '',
                                pr_cdoperad => '1',
                                pr_dsorigem => 'SCRIPT',
                                pr_dttransa => TRUNC(SYSDATE),
                                pr_flgtrans => 0,
                                pr_hrtransa => cecred.gene0002.fn_busca_time,
                                pr_idseqttl => 1,
                                pr_nmdatela => '',
                                pr_nrdrowid => vr_nrdrowid);  
    IF TRIM(pr_dsCampo) IS NOT NULL THEN
      cecred.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => pr_dsCampo,
                                       pr_dsdadant => pr_antes,
                                       pr_dsdadatu => pr_depois);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END registrarVERLOG;

  PROCEDURE prc_gera_lct(prm_cdcooper IN cecred.craplcm.cdcooper%TYPE
                        ,prm_nrdconta IN cecred.craplcm.nrdconta%TYPE
                        ,prm_vllanmto IN cecred.craplcm.vllanmto%TYPE
                        ,prm_cdhistor IN cecred.craplcm.cdhistor%TYPE) IS
    vr_dtmvtolt   cecred.craplcm.dtmvtolt%TYPE;
    vr_idprejuizo cecred.tbcc_prejuizo.idprejuizo%TYPE;
    vr_cdhistor   cecred.tbcc_prejuizo_detalhe.cdhistor%TYPE;
    vr_cdcritic   NUMBER;
    vr_dscritic   VARCHAR2(1000);
    vr_erro EXCEPTION;
  BEGIN
    BEGIN
      SELECT dtmvtolt
        INTO vr_dtmvtolt
        FROM cecred.crapdat
       WHERE cdcooper = prm_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar Data da Cooperatriva. Erro: ' || SubStr(SQLERRM, 1, 255);
        RAISE vr_erro;
    END;
  
    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (LCM VLR):');
    dbms_output.put_line('     Cooperativa....: ' || prm_cdcooper);
    dbms_output.put_line('     Conta..........: ' || prm_nrdconta);
    dbms_output.put_line('     Data...........: ' || To_Char(vr_dtmvtolt, 'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: ' || prm_vllanmto);
    dbms_output.put_line(' ');
  
    BEGIN
      SELECT a.idprejuizo
        INTO vr_idprejuizo
        FROM cecred.tbcc_prejuizo a
       WHERE a.cdcooper = prm_cdcooper
         AND a.nrdconta = prm_nrdconta
         AND ROWNUM = 1
       ORDER BY a.idprejuizo DESC;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar chave prejuizo. Erro: ' || SubStr(SQLERRM, 1, 255);
        RAISE vr_erro;
    END;
  
    cecred.prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => prm_cdcooper,
                                             pr_nrdconta   => prm_nrdconta,
                                             pr_dtmvtolt   => vr_dtmvtolt,
                                             pr_cdhistor   => prm_cdhistor,
                                             pr_idprejuizo => vr_idprejuizo,
                                             pr_vllanmto   => prm_vllanmto,
                                             pr_dthrtran   => SYSDATE,
                                             pr_cdcritic   => vr_cdcritic,
                                             pr_dscritic   => vr_dscritic);
    IF Nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_erro;
    ELSE
      dbms_output.put_line('   Lançamento do Histórico ' || prm_cdhistor || ' efetuado com Sucesso na Coop\Conta ' || prm_cdcooper || ' ' || prm_nrdconta );
    END IF;
  
    registrarVERLOG(pr_cdcooper => prm_cdcooper,
                    pr_nrdconta => prm_nrdconta,
                    pr_dstransa => 'Ajuste Contabil - ' || To_Char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'),
                    pr_dsCampo  => 'pc_gera_lcto_extrato_prj',
                    pr_antes    => '',
                    pr_depois   => prm_vllanmto);
  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_gera_lct: ' || vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001, vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_gera_lct: Erro: ' || SubStr(SQLERRM, 1, 255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002, 'Erro Geral no prc_gera_lct. Erro: ' || SubStr(SQLERRM, 1, 255));
  END prc_gera_lct;

  PROCEDURE prc_atlz_prejuizo(prm_cdcooper IN cecred.craplcm.cdcooper%TYPE
                             ,prm_nrdconta IN cecred.craplcm.nrdconta%TYPE
                             ,prm_vllanmto IN cecred.craplcm.vllanmto%TYPE
                             ,prm_cdhistor IN cecred.craplcm.cdhistor%TYPE
                             ,prm_tipoajus IN VARCHAR2) IS
    vr_idprejuizo cecred.tbcc_prejuizo.idprejuizo%TYPE;
    vr_tipoacao   BOOLEAN;
    vr_vlsdprej   cecred.tbcc_prejuizo.vlsdprej%TYPE;
    vr_cdcritic   NUMBER;
    vr_dscritic   VARCHAR2(1000);
    vr_erro EXCEPTION;
  BEGIN
    OPEN cr_sld_prj(pr_cdcooper => prm_cdcooper
                   ,pr_nrdconta => prm_nrdconta);
    FETCH cr_sld_prj
      INTO rw_sld_prj;
    vr_found      := cr_sld_prj%FOUND;
    vr_vlsdprej   := rw_sld_prj.vlsdprej;
    vr_idprejuizo := rw_sld_prj.idprejuizo;
    CLOSE cr_sld_prj;
  
    IF NOT vr_found THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro ao buscar Saldo Prejuizo Cop/Cta (' || prm_cdcooper || '/' || prm_nrdconta || ')';
      RAISE vr_erro;
    END IF;
    vr_found := NULL;
  
    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (prc_atlz_prejuizo):');
    dbms_output.put_line('     Cooperativa....: ' || prm_cdcooper);
    dbms_output.put_line('     Conta..........: ' || prm_nrdconta);
    dbms_output.put_line('     Valor..........: ' || prm_vllanmto);
    dbms_output.put_line('     Historico......: ' || prm_cdhistor);
    dbms_output.put_line('     Tipo Ajuste....: ' || prm_tipoajus);
    dbms_output.put_line('     Sld Prej. Antes: ' || vr_vlsdprej);
  
    IF prm_tipoajus IS NULL OR prm_tipoajus NOT IN ('E', 'I') THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: Tipo de Ajuste invalido! (' || prm_tipoajus || ')';
      RAISE vr_erro;
    END IF;
  
    OPEN cr_his(pr_cdcooper => prm_cdcooper, pr_cdhistor => prm_cdhistor);
    FETCH cr_his
      INTO rw_his;
    vr_found    := cr_his%FOUND;
    vr_indebcre := rw_his.indebcre;
    CLOSE cr_his;
  
    IF NOT vr_found THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: Historico não encontrato Cop/Hist (' || prm_cdcooper || '/' || prm_cdhistor || ')';
      RAISE vr_erro;
    END IF;
  
    IF prm_tipoajus = 'E' THEN
      IF vr_indebcre = 'C' THEN
        vr_tipoacao := TRUE;
      ELSE
        vr_tipoacao := FALSE;
      END IF;
    ELSE
      IF vr_indebcre = 'C' THEN
        vr_tipoacao := FALSE;
      ELSE
        vr_tipoacao := TRUE;
      END IF;
    END IF;
  
    IF vr_tipoacao THEN
      BEGIN
        UPDATE cecred.tbcc_prejuizo a
           SET a.vlsdprej = Nvl(vlsdprej, 0) - Nvl(prm_vllanmto, 0)
         WHERE a.cdcooper = prm_cdcooper
           AND a.nrdconta = prm_nrdconta
           AND a.idprejuizo = vr_idprejuizo;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: ' || SubStr(SQLERRM, 1, 255);
          RAISE vr_erro;
      END;
    ELSE
      BEGIN
        UPDATE cecred.tbcc_prejuizo a
           SET a.vlsdprej = Nvl(vlsdprej, 0) + Nvl(prm_vllanmto, 0)
         WHERE a.cdcooper = prm_cdcooper
           AND a.nrdconta = prm_nrdconta
           AND a.idprejuizo = vr_idprejuizo;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: ' || SubStr(SQLERRM, 1, 255);
          RAISE vr_erro;
      END;
    END IF;
  
    IF Nvl(SQL%ROWCOUNT, 0) > 0 THEN
      dbms_output.put_line('   Atualizado Saldo Devedor Prejuízo: ' || Nvl(SQL%ROWCOUNT, 0) || ' registro(s).');
    ELSE
      vr_dscritic := 'Conta não encontrada. Cooperativa: ' || prm_cdcooper || ' | Conta: ' || prm_nrdconta;
      RAISE vr_erro;
    END IF;
  
    vr_vlsdprej := 0;
    OPEN cr_sld_prj(pr_cdcooper => prm_cdcooper, pr_nrdconta => prm_nrdconta);
    FETCH cr_sld_prj
      INTO rw_sld_prj;
    vr_vlsdprej := rw_sld_prj.vlsdprej;
    CLOSE cr_sld_prj;
  
    dbms_output.put_line('     Sld Prej.Depois: ' || vr_vlsdprej);
  
    registrarVERLOG(pr_cdcooper => prm_cdcooper,
                    pr_nrdconta => prm_nrdconta,
                    pr_dstransa => 'Ajuste Contabil - ' || To_Char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'),
                    pr_dsCampo  => 'Saldo Prejuizo',
                    pr_antes    => vr_vlsdprej,
                    pr_depois   => rw_sld_prj.vlsdprej);
  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_atlz_prejuizo: ' || vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001, vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_atlz_prejuizo: Erro: ' || SubStr(SQLERRM, 1, 255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002, 'Erro Geral no prc_atlz_prejuizo. Erro: ' || SubStr(SQLERRM, 1, 255));
  END prc_atlz_prejuizo;

  PROCEDURE pc_grava_prejuizo_cc_forcado(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                                        ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE
                                        ,pr_tpope    IN VARCHAR2 DEFAULT 'N'
                                        ,pr_cdcritic OUT cecred.crapcri.cdcritic%TYPE
                                        ,pr_dscritic OUT VARCHAR2) IS
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT a.inprejuz
            ,a.vllimcre
            ,a.cdsitdct
        FROM cecred.crapass a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    CURSOR cr_qtdiaatr(pr_cdcooper crapris.cdcooper%TYPE
                      ,pr_nrdconta crapris.nrdconta%TYPE
                      ,pr_dtrefere crapris.dtrefere%TYPE) IS
      SELECT ris.qtdiaatr
        FROM cecred.crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.cdmodali = 101
         AND ris.dtrefere = pr_dtrefere;
  
    vr_cdcritic NUMBER(3);
    vr_dscritic VARCHAR2(1000);
    vr_des_erro VARCHAR2(1000);
    vr_exc_saida EXCEPTION;
  
    rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;
  
    vr_vlslddev NUMBER := 0;
    vr_tab_erro cecred.gene0001.typ_tab_erro;
  
    vr_qtdiaatr cecred.crapris.qtdiaatr%TYPE;
  
    vr_vlhist37 NUMBER;
    vr_vlhist38 NUMBER;
    vr_vlhist57 NUMBER;
  
    vr_vljuro60_37 NUMBER;
    vr_vljuro60_38 NUMBER;
    vr_vljuro60_57 NUMBER;
  
    vr_idprejuizo cecred.tbcc_prejuizo.idprejuizo%TYPE;
  BEGIN
    OPEN cecred.btch0001.cr_crapdat(pr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat
      INTO rw_crapdat;
  
    IF cecred.btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE cecred.btch0001.cr_crapdat;
    
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cecred.btch0001.cr_crapdat;
    END IF;
  
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
  
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;
  
    IF rw_crapass.inprejuz = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'A conta informada já está marcada como "Em prejuízo".';
      RAISE vr_exc_saida;
    END IF;
  
    cecred.PREJ0003.pc_cancela_servicos_cc_prj(pr_cdcooper       => pr_cdcooper,
                                               pr_nrdconta       => pr_nrdconta,
                                               pr_dtinc_prejuizo => rw_crapdat.dtmvtolt,
                                               pr_cdcritic       => vr_cdcritic,
                                               pr_dscritic       => vr_dscritic);  
    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao cancelar produtos/serviços para a conta ' || pr_nrdconta;
      RAISE vr_exc_saida;
    END IF;
  
    cecred.PREJ0003.pc_debita_juros60_prj(pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_vlhist37 => vr_vlhist37,
                                          pr_vlhist38 => vr_vlhist38,
                                          pr_vlhist57 => vr_vlhist57,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao debitar valores provisionados de juros +60 para conta ' || pr_nrdconta;
      RAISE vr_exc_saida;
    END IF;
  
    cecred.TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60_det(pr_cdcooper => pr_cdcooper,
                                                            pr_nrdconta => pr_nrdconta,
                                                            pr_vlsld59d => vr_vlslddev,
                                                            pr_vlju6037 => vr_vljuro60_37,
                                                            pr_vlju6038 => vr_vljuro60_38,
                                                            pr_vlju6057 => vr_vljuro60_57,
                                                            pr_cdcritic => vr_cdcritic,
                                                            pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao recuperar saldo devedor da conta corrente ' || pr_nrdconta;
      RAISE vr_exc_saida;
    END IF;
  
    OPEN cr_qtdiaatr(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_dtrefere => rw_crapdat.dtmvcentral);
    FETCH cr_qtdiaatr
      INTO vr_qtdiaatr;
  
    IF cr_qtdiaatr%NOTFOUND THEN
      vr_qtdiaatr := 0;
    END IF;
  
    CLOSE cr_qtdiaatr;
  
    BEGIN
      INSERT INTO cecred.TBCC_PREJUIZO
        (cdcooper
        ,nrdconta
        ,dtinclusao
        ,cdsitdct_original
        ,vldivida_original
        ,qtdiaatr
        ,vlsdprej
        ,vljur60_ctneg
        ,vljur60_lcred
        ,intipo_transf)
      VALUES
        (pr_cdcooper
        ,pr_nrdconta
        ,rw_crapdat.dtmvtolt
        ,rw_crapass.cdsitdct
        ,vr_vlslddev + vr_vljuro60_37 + vr_vljuro60_57 + vr_vljuro60_38
        ,vr_qtdiaatr
        ,vr_vlslddev
        ,vr_vljuro60_37 + vr_vljuro60_57
        ,vr_vljuro60_38
        ,CASE WHEN pr_tpope = 'N' THEN 0 ELSE 1 END)
      RETURNING idprejuizo INTO vr_idprejuizo;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro de insert na TBCC_PREJUIZO: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
  
    BEGIN
      UPDATE cecred.crapass a
         SET a.inprejuz = 1
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro de update na CRAPASS: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
  
    cecred.PREJ0003.pc_define_situacao_cc_prej(pr_cdcooper => pr_cdcooper,
                                               pr_nrdconta => pr_nrdconta,
                                               pr_cdcritic => vr_cdcritic,
                                               pr_dscritic => vr_dscritic);
    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    cecred.PREJ0003.pc_lanca_transf_extrato_prj(pr_idprejuizo    => vr_idprejuizo,
                                                pr_cdcooper      => pr_cdcooper,
                                                pr_nrdconta      => pr_nrdconta,
                                                pr_vlsldprj      => vr_vlslddev,
                                                pr_vljur60_ctneg => vr_vljuro60_37 + vr_vljuro60_57,
                                                pr_vljur60_lcred => vr_vljuro60_38,
                                                pr_dtmvtolt      => rw_crapdat.dtmvtolt,
                                                pr_tpope         => pr_tpope,
                                                pr_cdcritic      => vr_cdcritic,
                                                pr_dscritic      => vr_dscritic);
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := cecred.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
  END pc_grava_prejuizo_cc_forcado;

  PROCEDURE prc_gera_acerto_transit(prm_cdcooper IN cecred.craplcm.cdcooper%TYPE
                                   ,prm_nrdconta IN cecred.craplcm.nrdconta%TYPE
                                   ,prm_vllanmto IN cecred.craplcm.vllanmto%TYPE
                                   ,prm_idaument IN NUMBER DEFAULT 0) IS
    vr_dtmvtolt   cecred.craplcm.dtmvtolt%TYPE;
    vr_idprejuizo cecred.tbcc_prejuizo.idprejuizo%TYPE;
    vr_cdhistor   cecred.tbcc_prejuizo_detalhe.cdhistor%TYPE;
    vr_cdcritic   NUMBER;
    vr_dscritic   VARCHAR2(1000);
    vr_erro EXCEPTION;
  BEGIN
    BEGIN
      SELECT dtmvtolt
        INTO vr_dtmvtolt
        FROM cecred.crapdat
       WHERE cdcooper = prm_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar Data da Cooperatriva. Erro: ' || SubStr(SQLERRM, 1, 255);
        RAISE vr_erro;
    END;
  
    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (ATZ TRANSIT):');
    dbms_output.put_line('     Cooperativa....: ' || prm_cdcooper);
    dbms_output.put_line('     Conta..........: ' || prm_nrdconta);
    dbms_output.put_line('     Data...........: ' || To_Char(vr_dtmvtolt, 'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: ' || prm_vllanmto);
    dbms_output.put_line(' ');
  
    cecred.prej0003.pc_gera_cred_cta_prj(pr_cdcooper => prm_cdcooper,
                                         pr_nrdconta => prm_nrdconta,
                                         pr_vlrlanc  => prm_vllanmto,
                                         pr_dtmvtolt => vr_dtmvtolt,
                                         pr_dsoperac => 'Ajuste Contabil - ' || To_Char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'),
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);  
    IF Nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_erro;
    ELSE
      dbms_output.put_line('   Lançamento Credito Conta Transitoria efetuado com Sucesso na Coop/Conta ' || prm_cdcooper || '/' || prm_nrdconta || '.');
    END IF;
  
    registrarVERLOG(pr_cdcooper => prm_cdcooper,
                    pr_nrdconta => prm_nrdconta,
                    pr_dstransa => 'Ajuste Contabil - ' || To_Char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'),
                    pr_dsCampo  => 'pc_gera_cred_cta_prj',
                    pr_antes    => 0,
                    pr_depois   => prm_vllanmto);
  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_gera_acerto_transit: ' || vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001, vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_gera_acerto_transit: Erro: ' || SubStr(SQLERRM, 1, 255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002, 'Erro Geral no prc_gera_acerto_transit. Erro: ' || SubStr(SQLERRM, 1, 255));
  END prc_gera_acerto_transit;

  PROCEDURE pc_correcao_prejuizo(pr_cdcooper IN cecred.craplcm.cdcooper%TYPE
                                ,pr_nrdconta IN cecred.craplcm.nrdconta%TYPE
                                ,pr_vllanmto IN cecred.craplcm.vllanmto%TYPE
                                ,pr_cdhistor IN cecred.craplcm.cdhistor%TYPE
                                ,pr_flgpreju IN INTEGER DEFAULT 0
                                ,pr_flgconta IN INTEGER DEFAULT 0
                                ,pr_cdcritic OUT cecred.crapcri.cdcritic%TYPE
                                ,pr_dscritic OUT VARCHAR2) IS
    vr_erro EXCEPTION;
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(1000);
  BEGIN
    IF pr_cdhistor = 2408 THEN
      prc_gera_lct(prm_cdcooper => pr_cdcooper,
                   prm_nrdconta => pr_nrdconta,
                   prm_vllanmto => pr_vllanmto,
                   prm_cdhistor => pr_cdhistor);
    
      prc_atlz_prejuizo(prm_cdcooper => pr_cdcooper,
                        prm_nrdconta => pr_nrdconta,
                        prm_vllanmto => pr_vllanmto,
                        prm_cdhistor => pr_cdhistor,
                        prm_tipoajus => 'I');
    END IF;
  
    IF pr_cdhistor = 2721 THEN
      prc_gera_lct(prm_cdcooper => pr_cdcooper,
                   prm_nrdconta => pr_nrdconta,
                   prm_vllanmto => pr_vllanmto,
                   prm_cdhistor => pr_cdhistor);
    
      prc_atlz_prejuizo(prm_cdcooper => pr_cdcooper,
                        prm_nrdconta => pr_nrdconta,
                        prm_vllanmto => pr_vllanmto,
                        prm_cdhistor => pr_cdhistor,
                        prm_tipoajus => 'I');
    END IF;
  
    IF pr_cdhistor = 2738 THEN
      prc_gera_acerto_transit(prm_cdcooper => pr_cdcooper,
                              prm_nrdconta => pr_nrdconta,
                              prm_vllanmto => pr_vllanmto);
    END IF;
  
    IF NVL(pr_flgconta, 0) = 1 THEN
      OPEN cecred.BTCH0001.cr_crapdat(pr_cdcooper);
      FETCH cecred.BTCH0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE cecred.BTCH0001.cr_crapdat;
    
      vr_nrdocmto := fn_sequence('CRAPLCT',
                                 'NRDOCMTO',
                                 pr_cdcooper || ';' ||
                                 TRIM(to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY')) || ';' || 61);
    
      cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => pr_cdcooper,
                                                pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                pr_cdagenci    => 1,
                                                pr_cdbccxlt    => 1,
                                                pr_nrdolote    => 600040,
                                                pr_nrdctabb    => pr_nrdconta,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_cdhistor    => pr_cdhistor,
                                                pr_vllanmto    => pr_vllanmto,
                                                pr_nrdconta    => pr_nrdconta,
                                                pr_hrtransa    => cecred.gene0002.fn_busca_time,
                                                pr_cdorigem    => 0,
                                                pr_inprolot    => 1,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_incrineg    => vr_incrineg,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_erro;
      END IF;
    END IF;
  
    IF NVL(pr_flgpreju, 0) = 1 THEN
      pc_grava_prejuizo_cc_forcado(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_tpope    => 'N',
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic);
      IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_erro;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('pc_correcao_prejuizo: ' || vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001, vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('pc_correcao_prejuizo: Erro: ' || SubStr(SQLERRM, 1, 255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002, 'Erro Geral no pc_correcao_prejuizo. Erro: ' || SubStr(SQLERRM, 1, 255));
  END pc_correcao_prejuizo;
BEGIN
  dbms_output.put_line('Script iniciado em ' || to_Char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
  dbms_output.put_line('  ');

  vr_conta := cecred.GENE0002.fn_quebra_string(pr_string  => 
															'8;565146;2408;13,81;0;0|' ||
															'8;611321;2408;40,47;0;0|' ||
															'8;710015;2408;10,56;0;0|' ||
															'8;726286;2408;220,92;0;0|' ||
															'8;743191;2408;70,61;0;0|' ||
															'8;863161;2408;46,01;0;0|' ||
															'8;917710;2408;31,54;0;0|' ||
															'8;951114;2408;31,06;0;0|' ||
															'8;977131;2408;63,84;0;0|' ||
															'8;1020425;2408;48,16;0;0|' ||
															'8;1080314;2408;57,24;0;0|' ||
															'8;1094344;2408;29,84;0;0|' ||
															'8;1469926;2408;38,87;0;0|' ||
															'8;1566342;2408;26,26;0;0|' ||
															'8;466236;2408;15,76;0;0|' ||
															'8;593577;2408;14,98;0;0|' ||
															'8;731361;2408;15,16;0;0|' ||
															'8;796790;2408;15,64;0;0|' ||
															'8;822602;2408;0,95;0;0|' ||
															'8;845820;2408;15,72;0;0|' ||
															'8;888607;2408;16,79;0;0|' ||
															'8;917078;2408;16,15;0;0|' ||
															'8;932223;2408;16,91;0;0|' ||
															'8;995339;2408;20,93;0;0|' ||
															'8;1094091;2408;16,86;0;0|' ||
															'8;1133178;2408;5,70;0;0|' ||
															'8;1138681;2408;14,85;0;0|' ||
															'8;793510;2408;13,21;0;0|' ||
															'8;814827;2408;11,04;0;0|' ||
															'8;881238;2408;14,22;0;0|' ||
															'8;894133;2408;13,19;0;0|' ||
															'8;917053;2408;12,50;0;0|' ||
															'8;939606;2408;13,02;0;0|' ||
															'8;950435;2408;10,65;0;0|' ||
															'8;958277;2408;14,06;0;0|' ||
															'8;968814;2408;12,84;0;0|' ||
															'8;1031905;2408;0,04;0;0|' ||
															'8;1148456;2408;14,25;0;0|' ||
															'8;1336545;2408;12,20;0;0|' ||
															'8;888607;2721;16,79;0;0|' ||
															'8;927339;2721;1200,00;0;0|' ||
															'14;1126740;2408;13,49;0;0|' ||
															'14;1150493;2408;69,41;0;0|' ||
															'1;1565927;2738;2176,04;0;0|', ||
															'12;547912;2721;3,90;0;0|' ||
															'12;930797;2721;11,81;0;0|' ||
															'12;931981;2721;10,57;0;0|' ||
															'12;938915;2721;14,58;0;0|' ||
															'12;1094186;2721;9,40;0;0|' ||
															'12;1129619;2721;9,07;0;0|' ||
															'12;1160285;2721;12,29;0;0|' ||
															'12;1197094;2721;12,95;0;0|' ||
															'12;1271311;2721;12,26;0;0|' ||
															'12;1332535;2721;9,32;0;0|' ||
															'16;619369;2408;15,49;0;0|' ||
															'12;890543;2721;12,25;0;0|' ,
  
                                               pr_delimit => '|');
  IF vr_conta.COUNT > 0 THEN
    FOR vr_idx_lst IN 1 .. vr_conta.COUNT - 1 LOOP
      vr_reg_conta := cecred.GENE0002.fn_quebra_string(pr_string  => vr_conta(vr_idx_lst),
                                                       pr_delimit => ';');
    
      vr_cdcooper := vr_reg_conta(1);
      vr_progress := vr_reg_conta(2);
      vr_cdhistor := vr_reg_conta(3);
      vr_vllanmto := cecred.GENE0002.fn_char_para_number(pr_dsnumtex => vr_reg_conta(4));
      vr_flgpreju := vr_reg_conta(5);
      vr_flgconta := vr_reg_conta(6);
    
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_progress => vr_progress);
      FETCH cr_crapass
        INTO rw_crapass;
      IF cr_crapass%FOUND THEN
        pc_correcao_prejuizo(pr_cdcooper => vr_cdcooper,
                             pr_nrdconta => rw_crapass.nrdconta,
                             pr_vllanmto => vr_vllanmto,
                             pr_cdhistor => vr_cdhistor,
                             pr_flgpreju => vr_flgpreju,
                             pr_flgconta => vr_flgconta,
                             pr_cdcritic => vr_cdcritic,
                             pr_dscritic => vr_dscritic);
        IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_excerro;
        END IF;
      ELSE
        dbms_output.put_line('Conta nao encontrada - Progress_RECID: ' || vr_progress);
      END IF;
      CLOSE cr_crapass;   
      COMMIT;
    END LOOP;
  END IF;

  OPEN cr_crapass(pr_cdcooper => 1
                 ,pr_progress => 876934);
  FETCH cr_crapass
    INTO rw_crapass;
  IF cr_crapass%FOUND THEN       
	  prc_gera_lct(prm_cdcooper => 1,
                 prm_nrdconta => rw_crapass.nrdconta,
                 prm_vllanmto => 1585.40,
                 prm_cdhistor => 2722);
  ELSE
    dbms_output.put_line('Conta nao encontrada - Progress_RECID: ' || vr_progress);
  END IF;
  CLOSE cr_crapass;   
  COMMIT;  
  
  OPEN cr_crapass(pr_cdcooper => 1
                 ,pr_progress => 1565927);
  FETCH cr_crapass
    INTO rw_crapass;
  IF cr_crapass%FOUND THEN       
	  prc_gera_lct(prm_cdcooper => 1,
                 prm_nrdconta => rw_crapass.nrdconta,
                 prm_vllanmto => 2176.04,
                 prm_cdhistor => 2722);
  ELSE
    dbms_output.put_line('Conta nao encontrada - Progress_RECID: ' || vr_progress);
  END IF;
  CLOSE cr_crapass;   
  COMMIT;  
  
  OPEN cr_crapass(pr_cdcooper => 1
                 ,pr_progress => 1565927);
  FETCH cr_crapass
    INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    OPEN cecred.BTCH0001.cr_crapdat(1);
    FETCH cecred.BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE cecred.BTCH0001.cr_crapdat;
      
    vr_nrdocmto := fn_sequence('CRAPLCT',
                               'NRDOCMTO',
                               1 || ';' ||
                               TRIM(to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY')) || ';' || 61);
      
    cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => 1,
                                              pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                              pr_cdagenci    => 1,
                                              pr_cdbccxlt    => 1,
                                              pr_nrdolote    => 600040,
                                              pr_nrdctabb    => rw_crapass.nrdconta,
                                              pr_nrdocmto    => vr_nrdocmto,
                                              pr_cdhistor    => 2719,
                                              pr_vllanmto    => 2176.04,
                                              pr_nrdconta    => rw_crapass.nrdconta,
                                              pr_hrtransa    => cecred.gene0002.fn_busca_time,
                                              pr_cdorigem    => 0,
                                              pr_inprolot    => 1,
                                              pr_tab_retorno => vr_tab_retorno,
                                              pr_incrineg    => vr_incrineg,
                                              pr_cdcritic    => vr_cdcritic,
                                              pr_dscritic    => vr_dscritic);
    IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_excerro;
    END IF;
  ELSE
    dbms_output.put_line('Conta nao encontrada - Progress_RECID: ' || vr_progress);
  END IF;
  CLOSE cr_crapass;   
  COMMIT;
  
  BEGIN
     SELECT a.nrdconta into vr_nrdconta
      FROM cecred.crapass a
     WHERE a.cdcooper = 1
       AND a.progress_recid = 1565927;

       UPDATE cecred.tbcc_prejuizo
       SET vlsdprej = 0,
           vljuprej = 0,
           vljur60_ctneg = 0,
           vljur60_lcred = 0
       WHERE cdcooper = 1
       AND nrdconta = vr_nrdconta;
       COMMIT;
   END;  
				   
  dbms_output.put_line(' ');
  dbms_output.put_line('Script finalizado com Sucesso em ' || to_Char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN vr_excerro THEN
    dbms_output.put_line('Erro Geral no Script. Erro: ' || vr_dscritic);
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002, 'Erro Geral no Script. Erro: ' || vr_dscritic);
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: ' || SubStr(SQLERRM, 1, 255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002, 'Erro Geral no Script. Erro: ' || SubStr(SQLERRM, 1, 255));
END;
