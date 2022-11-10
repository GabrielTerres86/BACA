DECLARE
  
  CURSOR cr_contas IS
    SELECT t.cdcooper
         , t.nrdconta 
         , COUNT(*)
      FROM tbcc_portabilidade_recebe t
     WHERE t.idsituacao = 2
       AND t.cdcooper <> 3 
     GROUP BY t.cdcooper
            , t.nrdconta 
       HAVING COUNT(*) > 1;
       
  CURSOR cr_portab(pr_cdcooper  IN NUMBER
                  ,pr_nrdconta  IN NUMBER) IS
    SELECT *
      FROM (SELECT nrnu_portabilidade
                 , idsituacao
                 , dsdominio_motivo
                 , cdmotivo
                 , ROWNUM nrregistro
              FROM (SELECT t.nrnu_portabilidade
                         , t.idsituacao
                         , t.dsdominio_motivo
                         , t.cdmotivo
                      FROM tbcc_portabilidade_recebe t
                     WHERE t.cdcooper = pr_cdcooper
                       AND t.nrdconta = pr_nrdconta
                       AND t.idsituacao = 2
                     ORDER BY t.dtsolicitacao DESC))
    WHERE nrregistro > 1;
    
    
  vc_dstransa      CONSTANT VARCHAR2(4000) := 'Cancelamento de portabilidades antigas - PRB0047632';
  vr_dttransa      cecred.craplgm.dttransa%type;
  vr_hrtransa      cecred.craplgm.hrtransa%type;
  vr_nrdrowid      ROWID;
  vr_dscritic      VARCHAR2(1000);
  
  vr_nmdireto      VARCHAR2(100);
  vr_nmarqbkp      VARCHAR2(50) := 'PRB0047632_ROLLBACK_portabilidades.csv';
  vr_nmarqlog      VARCHAR2(50) := 'PRB0047632_log_execucao.txt';
  vr_ind_arquiv    UTL_FILE.FILE_TYPE;
  vr_ind_arqlog    UTL_FILE.FILE_TYPE;
  vr_exception     EXCEPTION;
  vr_qtdcommit     NUMBER := 0; 
  
BEGIN

  vr_dttransa := TRUNC(SYSDATE);
  vr_hrtransa := CECRED.GENE0002.fn_busca_time;
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/PRB0047632';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  
  
  FOR conta IN cr_contas LOOP
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => conta.cdcooper
                               ,pr_cdoperad => '1'
                               ,pr_dscritic => vr_dscritic
                               ,pr_dsorigem => 'AIMARO'
                               ,pr_dstransa => vc_dstransa
                               ,pr_dttransa => vr_dttransa
                               ,pr_flgtrans => 1
                               ,pr_hrtransa => vr_hrtransa
                               ,pr_idseqttl => 0
                               ,pr_nmdatela => NULL
                               ,pr_nrdconta => conta.nrdconta
                               ,pr_nrdrowid => vr_nrdrowid);
    
    FOR portab IN cr_portab(conta.cdcooper, conta.nrdconta) LOOP
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'NUPortabilidade'
                                      ,pr_dsdadant => portab.nrnu_portabilidade
                                      ,pr_dsdadatu => portab.nrnu_portabilidade);
      
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'Situação '||portab.nrnu_portabilidade
                                      ,pr_dsdadant => portab.idsituacao
                                      ,pr_dsdadatu => 5);
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, to_char(portab.nrnu_portabilidade)||';'||portab.idsituacao||';'||portab.dsdominio_motivo||';'||portab.cdmotivo);
      
      BEGIN
        
        UPDATE tbcc_portabilidade_recebe t
           SET t.idsituacao         = 5
             , t.dsdominio_motivo   = 'MOTVCANCELTPORTDDCTSALR'
             , t.cdmotivo           = 2
         WHERE t.nrnu_portabilidade = portab.nrnu_portabilidade;
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar portabilidade '||to_char(portab.nrnu_portabilidade)||': '||SQLERRM;
          RAISE vr_exception;
      END;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Portabilidade: '||to_char(portab.nrnu_portabilidade)||', da coop/conta: '||conta.cdcooper||'/'||conta.nrdconta||', cancelada.');
      
    END LOOP;
    
    vr_qtdcommit := NVL(vr_qtdcommit,0) + 1;
    
    IF vr_qtdcommit >= 100 THEN
      COMMIT;
      vr_qtdcommit := 0;
    END IF;
    
  END LOOP;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'SCRIPT EXECUTADO COM SUCESSO.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;

EXCEPTION 
  WHEN vr_exception THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
END;
