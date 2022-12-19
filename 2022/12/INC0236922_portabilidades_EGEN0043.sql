DECLARE 
  
  CURSOR cr_portab(pr_nrnuportab  NUMBER) IS
    SELECT t.cdcooper
         , t.nrdconta
         , t.idsituacao
         , t.dsdominio_motivo
         , t.cdmotivo
      FROM cecred.tbcc_portabilidade_envia t
     WHERE t.nrnu_portabilidade = pr_nrnuportab;
  rg_portab      cr_portab%ROWTYPE;
  
  vr_arq_path    VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/INC0236922'; 

  vr_nmarquiv    VARCHAR2(100) := 'INC0236922_APCS105_portabilidades_erro.txt';
  vr_nmarqrol    VARCHAR2(100) := 'INC0236922_ROLLBACK_PORTABILIDADES.sql';
  vr_nmarqlog    VARCHAR2(100) := 'INC0236922_log_processamento.txt';  

  vr_flarquiv    utl_file.file_type;
  vr_flarqrol    utl_file.file_type;
  vr_flarqlog    utl_file.file_type;
  
  vr_nrnuport    cecred.tbcc_portabilidade_envia.nrnu_portabilidade%TYPE;

  vr_dscritic    cecred.crapcri.dscritic%TYPE;
  vr_exc_erro    EXCEPTION;
  vr_des_erro    VARCHAR2(4000);
  vr_dsdlinha    VARCHAR2(2000);
   
BEGIN 
 
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarquiv   
                                 ,pr_tipabert => 'R'           
                                 ,pr_utlfileh => vr_flarquiv   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo '||vr_nmarquiv||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 
  
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarqlog   
                                 ,pr_tipabert => 'W'           
                                 ,pr_utlfileh => vr_flarqlog   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo '||vr_nmarqlog||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 
  
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarqrol   
                                 ,pr_tipabert => 'W'           
                                 ,pr_utlfileh => vr_flarqrol   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo '||vr_nmarqrol||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 
  
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                       ,pr_des_text => 'BEGIN');
  
  IF utl_file.IS_OPEN(vr_flarquiv) THEN
    
    LOOP  
      vr_nrnuport := NULL;
      
      BEGIN
        CECRED.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_flarquiv 
                                           ,pr_des_text => vr_dsdlinha); 
      EXCEPTION
        WHEN no_data_found THEN
          EXIT;
      END;
       
      IF LENGTH(vr_dsdlinha) <= 1 THEN 
        CONTINUE;
      END IF;
        
      vr_nrnuport := TRIM(vr_dsdlinha);
        
      OPEN  cr_portab(vr_nrnuport);
      FETCH cr_portab INTO rg_portab;
        
      IF cr_portab%NOTFOUND THEN 
        CLOSE cr_portab;
        
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'ERRO: Portabilidade '||vr_nrnuport||' nao encontrada.');
        CONTINUE;
      END IF;
        
      CLOSE cr_portab;
        
      IF rg_portab.idsituacao = 5 AND NVL(rg_portab.dsdominio_motivo,'@') = 'MOTVCANCELTPORTDDCTSALR' AND NVL(rg_portab.cdmotivo,0) IN (1,2) THEN
        CONTINUE;
        
      ELSIF NVL(rg_portab.dsdominio_motivo,'@') = 'MOTVREPRVCPORTDDCTSALR' THEN
          
        BEGIN
          UPDATE cecred.tbcc_portabilidade_envia t
             SET t.idsituacao = 4
           WHERE t.nrnu_portabilidade = vr_nrnuport;
               
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar situação da portabilidade '||vr_nrnuport||' para reprovada.';
            RAISE vr_exc_erro;
        END;
          
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                             ,pr_des_text => 'UPDATE cecred.tbcc_portabilidade_envia t SET t.idsituacao = '||rg_portab.idsituacao||' WHERE t.nrnu_portabilidade = '||vr_nrnuport||';');
          
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                             ,pr_des_text => 'Portabilidade '||vr_nrnuport||' da coop/conta '||rg_portab.cdcooper||'/'||rg_portab.nrdconta||' alterada para reprovada.');
          
      ELSIF rg_portab.idsituacao = 5 THEN
          
        BEGIN
          UPDATE cecred.tbcc_portabilidade_envia t
             SET t.dsdominio_motivo   = 'MOTVCANCELTPORTDDCTSALR'
               , t.cdmotivo           = 2
           WHERE t.nrnu_portabilidade = vr_nrnuport;
               
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar situação da portabilidade '||vr_nrnuport||' para reprovada.';
            RAISE vr_exc_erro;
        END;
          
        IF rg_portab.dsdominio_motivo IS NULL THEN
           CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                             ,pr_des_text => 'UPDATE cecred.tbcc_portabilidade_envia t SET t.dsdominio_motivo = NULL'
                                                           ||' , t.cdmotivo = NULL WHERE t.nrnu_portabilidade = '||vr_nrnuport||';');
        ELSE 
          CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                               ,pr_des_text => 'UPDATE cecred.tbcc_portabilidade_envia t SET t.dsdominio_motivo = '''||rg_portab.dsdominio_motivo
                                                             ||''' , t.cdmotivo = '||NVL(rg_portab.cdmotivo,'NULL')||' WHERE t.nrnu_portabilidade = '||vr_nrnuport||';');
        END IF;
               
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                             ,pr_des_text => 'Motivo de cancelamento da portabilidade '||vr_nrnuport||' da coop/conta '||rg_portab.cdcooper||'/'||rg_portab.nrdconta||' ajustada.');
                                  
      END IF; 
         
    END LOOP; 
  END IF;
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => 'COMMIT; ');
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => 'END; ');
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog,pr_des_text => 'Script executado com sucesso.');
  
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarquiv);
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
      
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => vr_dscritic);
    
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarquiv);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
    
    raise_application_error(-20001, vr_dscritic);
    
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'ERRO NO SCRIPT: '||SQLERRM);
    
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarquiv);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
  
    raise_application_error(-20000, 'ERRO NO SCRIPT: '||SQLERRM);
END;
