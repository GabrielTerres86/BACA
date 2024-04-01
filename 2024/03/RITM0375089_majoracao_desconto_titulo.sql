DECLARE
  vr_aux_ambiente INTEGER := 3;  
  vr_aux_diretor  VARCHAR2(100) := 'RITM0375089';
  vr_aux_arquivo  VARCHAR2(100) := 'desconto_titulo'; 
  vr_aux_cdcooper NUMBER := 11;
  vr_aux_produto  NUMBER := 3;
  vr_nmarq_carga  VARCHAR2(200);
  vr_nmarq_log    VARCHAR2(200);
  vr_nmarq_rollback VARCHAR2(200);
  vr_input_file UTL_FILE.FILE_TYPE; 
  vr_handle     UTL_FILE.FILE_TYPE; 
  vr_handle_log UTL_FILE.FILE_TYPE;
  vr_handle_rollback UTL_FILE.FILE_TYPE; 
  vr_nrcontad   PLS_INTEGER := 0;
  vr_idx_carga  PLS_INTEGER;                            
  vr_setlinha   VARCHAR2(5000);                  
  vr_vet_campos gene0002.typ_split;   
  vr_nrdrowid  ROWID;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  vr_des_erro VARCHAR2(10000); 

  CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE    
                   ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                   ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS 
   SELECT lim.cdcooper
         ,lim.nrdconta
         ,lim.nrctrlim
         ,lim.tpctrlim
         ,lim.vllimite
     FROM cecred.craplim lim
    WHERE lim.cdcooper = pr_cdcooper
      AND lim.nrctrlim = pr_nrctrlim
      AND lim.tpctrlim = pr_tpctrlim
      AND lim.insitlim = 2;
   rw_craplim cr_craplim%ROWTYPE; 
   
BEGIN 
  IF vr_aux_ambiente = 1 THEN
      vr_nmarq_carga    := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';        
      vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';
      vr_nmarq_rollback := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';
    ELSIF vr_aux_ambiente = 2 THEN
      vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';        
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt'; 
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';    
    ELSIF vr_aux_ambiente = 3 THEN
      vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv'; 
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt'; 
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';  
    ELSE
      vr_dscritic := 'Erro ao apontar ambiente de execucao.';
      RAISE vr_exc_erro;
    END IF;
      
    GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_carga
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_input_file
                            ,pr_des_erro => vr_des_erro);                                                                       
    IF vr_des_erro IS NOT NULL THEN 
       vr_dscritic := 'Erro ao abrir o arquivo para leitura: '||vr_nmarq_carga || ' - ' || vr_des_erro;
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
      
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                            ,pr_tipabert => 'W'              
                            ,pr_utlfileh => vr_handle_rollback   
                            ,pr_des_erro => vr_des_erro);
    if vr_des_erro is not null then
      vr_dscritic := 'Erro ao abrir arquivo de ROLLBACK: ' || vr_des_erro;
      RAISE vr_exc_erro;
    end if;
       
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Inicio da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Cooperativa;Contrato;Erro');
              
    LOOP
      BEGIN
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file 
                                    ,pr_des_text => vr_setlinha); 
      
        vr_nrcontad := vr_nrcontad + 1;
        vr_setlinha := REPLACE(REPLACE(vr_setlinha,chr(13),''),chr(10),'');
        vr_vet_campos := gene0002.fn_quebra_string(TRIM(vr_setlinha),';');

        OPEN cr_craplim(pr_cdcooper => vr_aux_cdcooper,
                        pr_nrctrlim => vr_vet_campos(1),
                        pr_tpctrlim => vr_aux_produto);
        FETCH cr_craplim INTO rw_craplim;
        IF cr_craplim%NOTFOUND THEN
           CLOSE cr_craplim;
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                         ,pr_des_text => vr_aux_cdcooper || ';' || vr_vet_campos(1) || ';' || 'Contrato Inativo.');
           CONTINUE;                               
        ELSE
           CLOSE cr_craplim;
        END IF; 
  
        BEGIN
          UPDATE cecred.craplim lim
             SET lim.vllimite = vr_vet_campos(2)
           WHERE lim.nrctrlim = rw_craplim.nrctrlim
             AND lim.nrdconta = rw_craplim.nrdconta
             AND lim.cdcooper = rw_craplim.cdcooper
             AND lim.tpctrlim = rw_craplim.tpctrlim;
                    
          UPDATE cecred.crawlim lim
             SET lim.vllimite = vr_vet_campos(2)
           WHERE lim.nrctrlim = rw_craplim.nrctrlim
             AND lim.nrdconta = rw_craplim.nrdconta
             AND lim.cdcooper = rw_craplim.cdcooper
             AND lim.tpctrlim = rw_craplim.tpctrlim;

           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_rollback
                                        ,pr_des_text => 'UPDATE cecred.craplim lim '    ||
                                                        '   SET lim.vllimite = ' || rw_craplim.vllimite ||
                                                        ' WHERE lim.cdcooper = ' || rw_craplim.cdcooper ||
                                                        '   AND lim.nrdconta = ' || rw_craplim.nrdconta ||
                                                        '   AND lim.nrctrlim = ' || rw_craplim.nrctrlim ||
                                                        '   AND lim.tpctrlim = ' || rw_craplim.tpctrlim ||
                                                        ';');

            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_rollback
                                          ,pr_des_text => 'UPDATE cecred.crawlim lim '    ||
                                                          '   SET lim.vllimite = ' || rw_craplim.vllimite ||
                                                          ' WHERE lim.cdcooper = ' || rw_craplim.cdcooper ||
                                                          '   AND lim.nrdconta = ' || rw_craplim.nrdconta ||
                                                          '   AND lim.nrctrlim = ' || rw_craplim.nrctrlim ||
                                                          '   AND lim.tpctrlim = ' || rw_craplim.tpctrlim ||
                                                          ';');
            
            TELA_ATENDA_DSCTO_TIT.pc_gravar_hist_alt_limite(pr_cdcooper => rw_craplim.cdcooper,
                                                            pr_nrdconta => rw_craplim.nrdconta,
                                                            pr_nrctrlim => rw_craplim.nrctrlim,
                                                            pr_tpctrlim => rw_craplim.tpctrlim,
                                                            pr_dsmotivo => 'Solicitacao ' || vr_aux_diretor,
                                                            pr_cdcritic => vr_cdcritic,
                                                            pr_dscritic => vr_dscritic);
  
            IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => rw_craplim.cdcooper || ';' ||  
                                                            rw_craplim.nrctrlim || ';' || 
                                                            'Erro na atualizacao do historico de atualizacao do contrato. pc_gravar_hist_alt_limite.' || sqlerrm);
            END IF; 
                                             
            GENE0001.pc_gera_log(pr_cdcooper => rw_craplim.cdcooper
                                ,pr_cdoperad => '1'
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                                ,pr_dstransa => 'Majoracao valor do limite - ' || vr_aux_diretor
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 1
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'Script'
                                ,pr_nrdconta => rw_craplim.nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
                                                                                            
            GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                      pr_nmdcampo => 'vllimite',
                                      pr_dsdadant => rw_craplim.vllimite,
                                      pr_dsdadatu => vr_vet_campos(2));                                                
        EXCEPTION
          WHEN OTHERS THEN
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => rw_craplim.cdcooper || ';' ||  
                                                          rw_craplim.nrctrlim || ';' || 
                                                          'Erro na atualizacao do contrato.' || sqlerrm);
        END;   

      EXCEPTION
        WHEN no_data_found THEN
          EXIT;
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na leitura da linha '||vr_nrcontad||' --> '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP; 
    
    COMMIT; 
 
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_rollback,pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_rollback); 
       
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,pr_des_text => 'Fim da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));        
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);          
          
EXCEPTION
    
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro arquivos: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro arquivos: ' || vr_dscritic || ' SQLERRM: ' || SQLERRM);      

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || vr_dscritic || ' - SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro geral: ' || ' SQLERRM: ' || SQLERRM);

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
END;
