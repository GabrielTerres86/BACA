DECLARE
  
  vr_aux_ambiente INTEGER       := 2;                
  vr_aux_diretor  VARCHAR2(100) := 'RITM0353215T';    
  vr_aux_arquivo  VARCHAR2(100) := 'contas_reducao'; 
  vr_aux_cdcooper NUMBER        := 2;                
    
  
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;

  
  vr_input_file UTL_FILE.FILE_TYPE; 
  vr_handle     UTL_FILE.FILE_TYPE; 
  vr_handle_log UTL_FILE.FILE_TYPE; 
  vr_nrcontad   PLS_INTEGER := 0;
  vr_idx_carga  PLS_INTEGER;                            
  vr_setlinha   VARCHAR2(5000);                
  vr_vet_campos gene0002.typ_split; 
  
  
  vr_nmarq_carga    VARCHAR2(200);
  vr_nmarq_log      VARCHAR2(200);
  vr_nmarq_rollback VARCHAR2(200);
  
  
  rw_crapdat        BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_erro       VARCHAR2(10000);   
  vr_aux_nrdconta   NUMBER;
  vr_aux_novolimite NUMBER;
  vr_tab_sald       EXTR0001.typ_tab_saldos;
  vr_des_reto       VARCHAR2(3);
  vr_tab_erro       GENE0001.typ_tab_erro;
 

  TYPE typ_reg_carga IS RECORD(cdcooper  craplim.cdcooper%TYPE
                              ,nrdconta  craplim.nrdconta%TYPE
                              ,vllimite  craplim.vllimite%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  
  
  CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     
                   ,pr_nrdconta IN craplim.nrdconta%TYPE) IS     
      SELECT craplim.cdcooper, 
             craplim.nrdconta, 
             craplim.nrctrlim,
             craplim.vllimite                       
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.tpctrlim = 3
         AND craplim.insitlim = 2;
    rw_craplim cr_craplim%ROWTYPE;

BEGIN 
  
  IF vr_aux_ambiente = 1 THEN       
    vr_nmarq_carga    := '/progress/t0035419/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';           
    vr_nmarq_log      := '/progress/t0035419/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';       
    vr_nmarq_rollback := '/progress/t0035419/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';  
  ELSIF vr_aux_ambiente = 2 THEN         
    vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';          
    vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
    vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
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
                              ,pr_des_erro => vr_dscritic);                                                                       
      IF vr_dscritic IS NOT NULL THEN 
         vr_dscritic := 'Erro ao abrir o arquivo para leitura: '||vr_nmarq_carga || ' - ' || vr_dscritic;
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
             
      LOOP 
        BEGIN
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file 
                                      ,pr_des_text => vr_setlinha); 
      
          vr_nrcontad := vr_nrcontad + 1; 
          
          IF vr_nrcontad = 1 THEN 
            continue;
          END IF;

          vr_setlinha := REPLACE(REPLACE(vr_setlinha,chr(13),''),chr(10),''); 

          vr_vet_campos := gene0002.fn_quebra_string(TRIM(vr_setlinha),';');  
          
          IF vr_nrcontad = 2 THEN             
            OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_aux_cdcooper); 
            FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
            CLOSE BTCH0001.cr_crapdat;
          END IF;
                    
          BEGIN
            vr_aux_nrdconta := TO_NUMBER(vr_vet_campos(1));
            vr_aux_novolimite := TO_NUMBER(vr_vet_campos(2));
          EXCEPTION
            WHEN OTHERS THEN
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' --> ' || SQLERRM);
              
            CONTINUE;
          END;             
          
          vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
          vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;
          vr_tab_carga(vr_nrcontad).vllimite := vr_aux_novolimite;

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
            
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Coop;Conta;Contrato;Critica');
   
      
      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                              ,pr_tipabert => 'W'              
                              ,pr_utlfileh => vr_handle   
                              ,pr_des_erro => vr_des_erro);
      if vr_des_erro is not null then
        vr_dscritic := 'Erro ao abrir arquivo de ROLLBACK: ' || vr_des_erro;
        RAISE vr_exc_erro;
      end if;                                               
 
      FOR vr_idx1 IN vr_tab_carga.first .. vr_tab_carga.last LOOP
          IF vr_tab_carga.exists(vr_idx1) THEN 
              
              OPEN cr_craplim(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper,
                              pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta);
              FETCH cr_craplim INTO rw_craplim;
              
              IF cr_craplim%NOTFOUND THEN
                CLOSE cr_craplim;
                vr_dscritic := 'Associado nao possui proposta de limite de credito Ativa. ';
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                              vr_tab_carga(vr_idx1).nrdconta || ';' || 
                                                              vr_dscritic);
                                                                                                            
              ELSE
                  CLOSE cr_craplim;
                    
                    extr0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_craplim.cdcooper
                                               ,pr_rw_crapdat => rw_crapdat
                                               ,pr_cdagenci   => 1
                                               ,pr_nrdcaixa   => 1
                                               ,pr_cdoperad   => '1'
                                               ,pr_nrdconta   => rw_craplim.nrdconta
                                               ,pr_vllimcre   => rw_craplim.vllimite
                                               ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                               ,pr_flgcrass   => FALSE
                                               ,pr_des_reto   => vr_des_reto
                                               ,pr_tab_sald   => vr_tab_sald
                                               ,pr_tab_erro   => vr_tab_erro);
                      
                  IF vr_des_reto = 'NOK' THEN
                     vr_dscritic := 'Erro ao buscar saldo. - ' ||  vr_tab_erro(vr_tab_erro.first).dscritic || ' - ' || SQLERRM;
                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                   ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                   vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                   rw_craplim.nrctrlim || ';' || 
                                                                   vr_dscritic);                                                                                                             
                                                                   
                    vr_tab_erro.DELETE; 
                    CONTINUE;
                  END IF;
                  
                  
                  IF  vr_tab_sald(0).vllimcre > 0 AND 
                     (vr_tab_sald(0).vlsddisp + vr_tab_carga(vr_idx1).vllimite) >= 0 THEN
                                                                     
                          BEGIN
                            UPDATE craplim SET
                                   vllimite = vr_tab_carga(vr_idx1).vllimite
                             WHERE cdcooper = rw_craplim.cdcooper
                               AND nrdconta = rw_craplim.nrdconta
                               AND nrctrlim = rw_craplim.nrctrlim
                               AND insitlim = 2 
                               AND tpctrlim = 3; 
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_dscritic := 'Erro ao ajustar o limite de credito: (craplim)' || SQLERRM;
                              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                            ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                            vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                            rw_craplim.nrctrlim || ';' || 
                                                                            vr_dscritic);
                          END;
                                                       
                          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                        ,pr_des_text => 'UPDATE craplim SET '
                                                                        ||' vllimite = '||''''||rw_craplim.vllimite||''''
                                                                        ||' WHERE cdcooper = '||rw_craplim.cdcooper
                                                                        ||'   AND nrdconta = '||rw_craplim.nrdconta
                                                                        ||'   AND nrctrlim = '||rw_craplim.nrctrlim
                                                                        ||'   AND insitlim = 2'
                                                                        ||'   AND tpctrlim = 3;'         
                                                                         );                                                                        
                          BEGIN
                            UPDATE crawlim SET
                                   vllimite = vr_tab_carga(vr_idx1).vllimite
                             WHERE cdcooper = rw_craplim.cdcooper
                               AND nrdconta = rw_craplim.nrdconta
                               AND nrctrlim = rw_craplim.nrctrlim
                               AND insitlim = 2; 
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_dscritic := 'Erro ao ajustar o limite de credito: (crawlim)' || SQLERRM;
                              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                            ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                            vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                            rw_craplim.nrctrlim || ';' || 
                                                                            vr_dscritic);
                          END;
                                                       
                          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                        ,pr_des_text => 'UPDATE crawlim SET '
                                                                        ||' vllimite = '||''''||rw_craplim.vllimite||''''
                                                                        ||' WHERE cdcooper = '||rw_craplim.cdcooper
                                                                        ||'   AND nrdconta = '||rw_craplim.nrdconta
                                                                        ||'   AND nrctrlim = '||rw_craplim.nrctrlim
                                                                        ||'   AND insitlim = 2;'     
                                                                         );                                               
                          
                                                                                                      
                          BEGIN
                            UPDATE crapass SET
                                   vllimcre = vr_tab_carga(vr_idx1).vllimite
                             WHERE cdcooper = rw_craplim.cdcooper
                               AND nrdconta = rw_craplim.nrdconta; 
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_dscritic := 'Erro ao ajustar o limite de credito: (crapass)' || SQLERRM;
                              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                            ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                            vr_tab_carga(vr_idx1).nrdconta || ';' || 
                                                                            rw_craplim.nrctrlim || ';' || 
                                                                            vr_dscritic);
                          END;
                                                       
                          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                        ,pr_des_text => 'UPDATE crapass SET '
                                                                        ||' vllimcre = '||''''||rw_craplim.vllimite||''''
                                                                        ||' WHERE cdcooper = '||rw_craplim.cdcooper
                                                                        ||'   AND nrdconta = '||rw_craplim.nrdconta || ';'  
                                                                         ); 
                              
                  ELSE
                     vr_dscritic := 'Nao foi possivel atualizar o limite de credito. - (Sem limite disponivel ou Limite de credito ficaria negativo.) ' ||  
                                    ' - Saldo disponivel:'|| vr_tab_sald(0).vlsddisp ||
                                    ' - Novo Limite:'|| vr_tab_carga(vr_idx1).vllimite ||
                                    ' - Limite contratado:'|| vr_tab_sald(0).vllimcre ||
                                    ' - Limite utilizado:'|| vr_tab_sald(0).vllimutl;
                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                   ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                   vr_tab_carga(vr_idx1).nrdconta || ';' ||
                                                                   rw_craplim.nrctrlim || ';' || 
                                                                   vr_dscritic);
                  END IF;
                                   
                  COMMIT;                                               
              END IF;

          END IF;
      END LOOP;
              
            
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Fim da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
                                     
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,pr_des_text => 'COMMIT;');
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
          
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
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro geral: ' || ' SQLERRM: ' || SQLERRM);

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
END;
