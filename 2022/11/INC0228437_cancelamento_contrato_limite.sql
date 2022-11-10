DECLARE
  vr_cdcooper  craplim.cdcooper%TYPE := 5;
  vr_nrdconta  craplim.nrdconta%TYPE := 99729601; -- 270334
  vr_nrctrlim  craplim.nrctrlim%TYPE := 104819;
  vr_nrcpf     crapass.nrcpfcgc%TYPE := '18645070000162'; -- 7952606000176
  vr_tpctrlim  craplim.tpctrlim%TYPE := 1;
  vr_cdoperad  craplim.cdopecan%TYPE := 1;
  vr_cdagenci  crawlim.cdagenci%TYPE := 0;
  vr_nrdcaixa  NUMBER := 0;
  vr_idorigem  NUMBER := 5;
  vr_dsorigem  VARCHAR2(100);
  vr_dsproduto VARCHAR2(100) := 'Desconto de Cheque Especial';
  vr_dstransa  craplgm.dstransa%TYPE := 'Efetuar cancelamente de limite de cheque especial';
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
      FROM CECRED.crawlim lim
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
      FROM CECRED.craplim lim
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
    UPDATE CECRED.craplim lim
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

  RATI0001.pc_desativa_rating(pr_cdcooper   => vr_cdcooper,
                              pr_cdagenci   => vr_cdagenci,
                              pr_nrdcaixa   => vr_nrdcaixa,
                              pr_cdoperad   => vr_cdoperad,
                              pr_rw_crapdat => rw_crapdat,
                              pr_nrdconta   => vr_nrdconta,
                              pr_tpctrrat   => vr_tpctrlim,
                              pr_nrctrrat   => rw_craplim.nrctrlim,
                              pr_flgefeti   => 'S',
                              pr_idseqttl   => 1,
                              pr_idorigem   => vr_idorigem,
                              pr_inusatab   => vr_inusatab,
                              pr_nmdatela   => 'ATENDA',
                              pr_flgerlog   => 'N',
                              pr_des_reto   => vr_des_erro,
                              pr_tab_erro   => vr_tab_erro);

  IF vr_des_erro = 'NOK' THEN
    IF vr_tab_erro.COUNT = 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro na RATI0001.pc_desativa_rating';
    ELSE
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
    END IF;
    RAISE vr_exc_erro;
  END IF;

  BEGIN
    UPDATE CECRED.crawlim lim
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
  
  
  BEGIN
    UPDATE CECRED.crapass ass
       SET ass.vllimcre = 0
          ,ass.dtultlcr = rw_crapdat.dtmvtolt
     WHERE ass.cdcooper = vr_cdcooper
       AND ass.nrcpfcgc = vr_nrcpf
       AND ass.nrdconta = vr_nrdconta;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao atualizar crapass. ' || SQLERRM;
      RAISE vr_exc_erro;
  END;


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
