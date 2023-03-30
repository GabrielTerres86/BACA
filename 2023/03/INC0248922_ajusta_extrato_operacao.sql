DECLARE

  vr_aux_ambiente INTEGER       := 3;                       
  vr_aux_diretor  VARCHAR2(100) := 'INC0248922'; 
  vr_aux_arquivo  VARCHAR2(100) := 'difcontab';
  
  vr_cdcooper crapcop.cdcooper%TYPE := 1;
  vr_nrdconta crapass.nrdconta%TYPE := 11422092;
  vr_nrborder crapbdt.nrborder%TYPE := 1349566;
  
  vr_nmarq_log      VARCHAR2(200);

  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  vr_des_erro       VARCHAR2(10000);   
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  
  vr_handle_log     UTL_FILE.FILE_TYPE;  

BEGIN
  
  IF vr_aux_ambiente = 1 THEN      
    vr_nmarq_log      := '/progress/f0030250/micros/cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
  ELSIF vr_aux_ambiente = 2 THEN      
    vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
  ELSIF vr_aux_ambiente = 3 THEN 
    vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
  ELSE
    vr_dscritic := 'Erro ao apontar ambiente de execucao.';
    RAISE vr_exc_erro;
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log
                          ,pr_tipabert => 'W'              
                          ,pr_utlfileh => vr_handle_log   
                          ,pr_des_erro => vr_des_erro);
  if vr_des_erro is not null then
    vr_dscritic := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
    RAISE vr_exc_erro;
  end if;
  
  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                ,pr_des_text => 'Inicio da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
  
  OPEN  btch0001.cr_crapdat(pr_cdcooper => 1);
  FETCH btch0001.cr_crapdat into rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  
  DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => vr_cdcooper, 
                                         pr_nrdconta => vr_nrdconta, 
                                         pr_nrborder => vr_nrborder,
                                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                         pr_cdorigem => 1, 
                                         pr_cdhistor => 2671, 
                                         pr_vllanmto => 957.85, 
                                         pr_cdbandoc => 85, 
                                         pr_nrdctabb => 101002, 
                                         pr_nrcnvcob => 101002, 
                                         pr_nrdocmto => 435, 
                                         pr_nrtitulo => 3, 
                                         pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN

    vr_dscritic := 'Erro ao fazer lancamento(pc_inserir_lancamento_bordero) - cdhistor 2671. ' || SQLERRM;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                 ,pr_des_text => vr_cdcooper || ';' || 
                                                                 vr_nrdconta || ';' ||
                                                                 vr_nrborder || ';' ||
                                                                 '957,85' || ';' ||
                                                                 vr_dscritic);
                                                  
    RAISE vr_exc_erro;
  END IF;
  
  
  DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => vr_cdcooper, 
                                         pr_nrdconta => vr_nrdconta, 
                                         pr_nrborder => vr_nrborder,
                                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                         pr_cdorigem => 1, 
                                         pr_cdhistor => 2668, 
                                         pr_vllanmto => 9.57, 
                                         pr_cdbandoc => 85, 
                                         pr_nrdctabb => 101002, 
                                         pr_nrcnvcob => 101002, 
                                         pr_nrdocmto => 435, 
                                         pr_nrtitulo => 3, 
                                         pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN

    vr_dscritic := 'Erro ao fazer lancamento(pc_inserir_lancamento_bordero) - cdhistor 2668. ' || SQLERRM;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                 ,pr_des_text => vr_cdcooper || ';' || 
                                                                 vr_nrdconta || ';' ||
                                                                 vr_nrborder || ';' ||
                                                                 '9,57' || ';' ||
                                                                 vr_dscritic);
                                                  
    RAISE vr_exc_erro;
  END IF;
  
  
  DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => vr_cdcooper, 
                                         pr_nrdconta => vr_nrdconta, 
                                         pr_nrborder => vr_nrborder,
                                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                         pr_cdorigem => 1, 
                                         pr_cdhistor => 2669, 
                                         pr_vllanmto => 18.73, 
                                         pr_cdbandoc => 85, 
                                         pr_nrdctabb => 101002, 
                                         pr_nrcnvcob => 101002, 
                                         pr_nrdocmto => 435, 
                                         pr_nrtitulo => 3, 
                                         pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN

    vr_dscritic := 'Erro ao fazer lancamento(pc_inserir_lancamento_bordero) - cdhistor 2669. ' || SQLERRM;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                 ,pr_des_text => vr_cdcooper || ';' || 
                                                                 vr_nrdconta || ';' ||
                                                                 vr_nrborder || ';' ||
                                                                 '18,73' || ';' ||
                                                                 vr_dscritic);
                                                  
    RAISE vr_exc_erro;
  END IF;
  
  
  DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => vr_cdcooper, 
                                         pr_nrdconta => vr_nrdconta, 
                                         pr_nrborder => vr_nrborder,
                                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                         pr_cdorigem => 1, 
                                         pr_cdhistor => 2667, 
                                         pr_vllanmto => 3.99, 
                                         pr_cdbandoc => 85, 
                                         pr_nrdctabb => 101002, 
                                         pr_nrcnvcob => 101002, 
                                         pr_nrdocmto => 435, 
                                         pr_nrtitulo => 3, 
                                         pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN

    vr_dscritic := 'Erro ao fazer lancamento(pc_inserir_lancamento_bordero) - cdhistor 2667. ' || SQLERRM;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                 ,pr_des_text => vr_cdcooper || ';' || 
                                                                 vr_nrdconta || ';' ||
                                                                 vr_nrborder || ';' ||
                                                                 '3,99' || ';' ||
                                                                 vr_dscritic);
                                                  
    RAISE vr_exc_erro;
  END IF;
  
  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                ,pr_des_text => 'Fim da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));      
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log); 
   
  COMMIT;  
  
EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro arquivos: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro arquivos: ' || vr_dscritic || ' SQLERRM: ' || SQLERRM);      
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
  
END;
