DECLARE
  vr_cdcooper  craplim.cdcooper%TYPE := 1;
  vr_nrdconta  craplim.nrdconta%TYPE := 2133164;
  vr_nrctrlim  craplim.nrctrlim%TYPE := 28006;
  vr_tpctrlim  craplim.tpctrlim%TYPE := 2;
  vr_cdoperad  craplim.cdopecan%TYPE := 1;
  vr_cdagenci  crawlim.cdagenci%TYPE := 0;
  vr_nrdcaixa  NUMBER := 0;
  vr_idorigem  NUMBER := 5;
  vr_dsorigem  VARCHAR2(100);
  vr_dsproduto VARCHAR2(100) := 'Desconto de Cheque';
  vr_dstransa  craplgm.dstransa%TYPE := 'Efetuar cancelamento de limite de desconto de cheque';
  vr_inusatab  BOOLEAN := FALSE;
  vr_rowid_log ROWID;
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_erro EXCEPTION;
  vr_des_erro VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;
  

  CURSOR cr_crawlim(pr_cdcooper IN craplim.cdcooper%TYPE
                   ,pr_nrdconta IN craplim.nrdconta%TYPE
                   ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                   ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
    SELECT lim.insitlim
          ,lim.insitest
          ,lim.cdcooper
          ,lim.nrdconta
          ,lim.nrctrlim
          ,lim.tpctrlim
      FROM cecred.crawlim lim
     WHERE lim.cdcooper = pr_cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrlim
       AND lim.tpctrlim = pr_tpctrlim;
  rw_crawlim cr_crawlim%ROWTYPE;

  CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                   ,pr_nrdconta IN craplim.nrdconta%TYPE
                   ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                   ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS  
    SELECT lim.insitlim
          ,lim.idcobope
          ,lim.nrctrlim
          ,lim.inbaslim
      FROM cecred.craplim lim
     WHERE lim.cdcooper = pr_cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrlim
       AND lim.tpctrlim = pr_tpctrlim;
  rw_craplim cr_craplim%ROWTYPE;

BEGIN

  OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH BTCH0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;

  OPEN cr_craplim(pr_cdcooper => vr_cdcooper,
                  pr_nrdconta => vr_nrdconta,
                  pr_nrctrlim => vr_nrctrlim,
                  pr_tpctrlim => vr_tpctrlim);
  FETCH cr_craplim
    INTO rw_craplim;

  IF cr_craplim%NOTFOUND THEN
    CLOSE cr_craplim;
    vr_dscritic := 'Registro de limites nao encontrado.';
    RAISE vr_exc_erro;
  ELSE
    CLOSE cr_craplim;
  END IF;

  IF rw_craplim.insitlim <> 2 THEN
    vr_dscritic := 'O contrato DEVE estar ATIVO.';
    RAISE vr_exc_erro;
  END IF;

  BEGIN
    UPDATE cecred.craplim lim
       SET lim.insitlim = 3
          ,lim.dtcancel = rw_crapdat.dtmvtolt
          ,lim.cdopeexc = vr_cdoperad
          ,lim.cdageexc = vr_cdagenci
          ,lim.dtinsexc = trunc(SYSDATE)
          ,lim.cdopecan = vr_cdoperad
     WHERE lim.cdcooper = vr_cdcooper
       AND lim.nrdconta = vr_nrdconta
       AND lim.nrctrlim = vr_nrctrlim
       AND lim.tpctrlim = vr_tpctrlim;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao cancelar o contrato de limite de ' || vr_dsproduto || '. ' || SQLERRM;
      RAISE vr_exc_erro;
  END;

  BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_nmdatela         => 'ATENDA',
                                        pr_idcobertura      => rw_craplim.idcobope,
                                        pr_inbloq_desbloq   => 'D',
                                        pr_cdoperador       => vr_cdoperad,
                                        pr_flgerar_log      => 'S',
                                        pr_atualizar_rating => 0,
                                        pr_dscritic         => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  BEGIN
    UPDATE cecred.crawlim lim
       SET lim.insitlim = 3
          ,lim.dtcancel = rw_crapdat.dtmvtolt
          ,lim.cdopeexc = vr_cdoperad
          ,lim.cdageexc = vr_cdagenci
          ,lim.dtinsexc = trunc(SYSDATE)
          ,lim.cdopecan = vr_cdoperad
     WHERE lim.cdcooper = vr_cdcooper
       AND lim.nrdconta = vr_nrdconta
       AND lim.nrctrlim = vr_nrctrlim
       AND lim.tpctrlim = vr_tpctrlim;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao cancelar a proposta de limite de ' || vr_dsproduto || '. ' || SQLERRM;
      RAISE vr_exc_erro;
  END;

  CREDITO.incluirHistoricoLimite(pr_cdcooper => vr_cdcooper,
                                 pr_nrdconta => vr_nrdconta,
                                 pr_nrctrlim => vr_nrctrlim,
                                 pr_tpctrlim => vr_tpctrlim,
                                 pr_dsmotivo => 'CANCELAMENTO',
                                 pr_cdcritic => vr_cdcritic,
                                 pr_dscritic => vr_dscritic);
  IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;


  SISTEMA.geraLog(pr_cdcooper => vr_cdcooper,
                  pr_cdoperad => vr_cdoperad,
                  pr_dscritic => '',
                  pr_dsorigem => canalEntrada(vr_idorigem).dscanal,
                  pr_dstransa => vr_dstransa || vr_dsproduto,
                  pr_dttransa => trunc(SYSDATE),
                  pr_flgtrans => 1,
                  pr_hrtransa => buscarTime,
                  pr_idseqttl => 1,
                  pr_nmdatela => 'ATENDA',
                  pr_nrdconta => vr_nrdconta,
                  pr_nrdrowid => vr_rowid_log);
  
  SISTEMA.geraLogItem(pr_nrdrowid => vr_rowid_log,
                      pr_nmdcampo => 'nrctrlim',
                      pr_dsdadant => '',
                      pr_dsdadatu => vr_nrctrlim);
              
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro: ' || vr_dscritic);
    ROLLBACK; 
    
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    ROLLBACK;
END;
