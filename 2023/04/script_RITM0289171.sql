DECLARE
  vr_aux_ambiente INTEGER       := 2;  
  vr_aux_diretor  VARCHAR2(100) := 'RITM0289171';
  vr_aux_arquivo  VARCHAR2(100) := 'desbloqueiopraprv';   
  vr_handle_regs  UTL_FILE.FILE_TYPE;
  vr_handle_log   UTL_FILE.FILE_TYPE;
  vr_nmarq_regs   VARCHAR2(200);
  vr_nmarq_log    VARCHAR2(200);
  vr_des_erro     VARCHAR2(10000);   
  vr_cdcritic     crapcri.cdcritic%TYPE;
  vr_dscritic     crapcri.dscritic%TYPE;
  vr_exc_erro     EXCEPTION; 
  vr_des_linha    VARCHAR2(3000);  
  vr_vet_campos   GENE0002.typ_split; 
  vr_nrcontad     PLS_INTEGER := 0;
  vr_contcommit   PLS_INTEGER := 0;
  
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrcpfcnpj IN crapass.nrcpfcnpj_base%TYPE) IS
    SELECT ass.cdcooper
          ,ass.nrdconta
          ,ass.inpessoa
          ,ass.nrcpfcnpj_base
     FROM crapass ass
    WHERE ass.cdcooper = pr_cdcooper
      AND ass.nrcpfcnpj_base = pr_nrcpfcnpj;
   rw_crapass cr_crapass%ROWTYPE;  
    
BEGIN
    IF vr_aux_ambiente = 1 THEN
      vr_nmarq_regs     := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';        
      vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';
    ELSIF vr_aux_ambiente = 2 THEN
      vr_nmarq_regs     := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';        
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
    ELSIF vr_aux_ambiente = 3 THEN
      vr_nmarq_regs     := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv'; 
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';   
    ELSE
      vr_dscritic := 'Erro ao apontar ambiente de execucao.';
      RAISE vr_exc_erro;
    END IF;

    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log
                            ,pr_tipabert => 'W'              
                            ,pr_utlfileh => vr_handle_log   
                            ,pr_des_erro => vr_des_erro);
    IF vr_des_erro IS NOT NULL THEN 
      vr_dscritic := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
      RAISE vr_exc_erro;
    end if;
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Inicio da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Cooperativa;CPF;Erro');                                                                                                           

    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_regs
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_handle_regs
                            ,pr_des_erro => vr_des_erro);                                                                       
    IF vr_des_erro IS NOT NULL THEN 
       vr_dscritic := 'Erro ao abrir o arquivo para leitura: '|| vr_des_erro;
       RAISE vr_exc_erro;
    END IF;   
       
    LOOP 
       BEGIN
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_regs 
                                      ,pr_des_text => vr_des_linha); 
        
          vr_nrcontad := vr_nrcontad + 1;
          vr_contcommit := vr_contcommit + 1;
          vr_des_linha := REPLACE(REPLACE(vr_des_linha,chr(13),''),chr(10),''); 
          vr_vet_campos := gene0002.fn_quebra_string(TRIM(vr_des_linha),';'); 
          
          OPEN cr_crapass (pr_cdcooper  => GENE0002.fn_char_para_number(vr_vet_campos(1))
                          ,pr_nrcpfcnpj => GENE0002.fn_char_para_number(vr_vet_campos(3)));
          FETCH cr_crapass INTO rw_crapass;
          IF cr_crapass%NOTFOUND THEN
            CLOSE cr_crapass;
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => vr_vet_campos(1) || ';' || vr_vet_campos(3) || ';' || 'Conta não encontrada.');
            CONTINUE;                      
          END IF;
          CLOSE cr_crapass;
 
          cada0006.pc_mantem_param_pessoa_prod(pr_cdcooper           => rw_crapass.cdcooper,
                                               pr_nrdconta           => rw_crapass.nrdconta,
                                               pr_cdproduto          => 56,
                                               pr_cdoperac_produto   => 1,
                                               pr_flglibera          => 1,
                                               pr_dtvigencia_paramet => NULL,
                                               pr_idmotivo           => 101,
                                               pr_cdoperad           => '1',
                                               pr_idorigem           => 5,
                                               pr_nmdatela           => 'TELA_ATENDA_PREAPV',
                                               pr_dscritic           => vr_dscritic); 
          IF vr_dscritic IS NOT NULL THEN
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                           ,pr_des_text => rw_crapass.cdcooper || ';' || rw_crapass.nrdconta || ';' || vr_dscritic);
             CONTINUE;    
          ELSE
            IF vr_contcommit = 500 THEN
               vr_contcommit := 0;
               COMMIT;
            END IF;
          END IF;

       EXCEPTION
          WHEN no_data_found THEN
            EXIT;
          WHEN vr_exc_erro THEN
            RAISE vr_exc_erro;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na leitura da linha '||vr_nrcontad||' => '||SQLERRM;
            RAISE vr_exc_erro;
      END;
    END LOOP;

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
