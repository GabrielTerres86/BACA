DECLARE
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  vr_input_file           UTL_FILE.FILE_TYPE;
  vr_handle               UTL_FILE.FILE_TYPE;
  vr_handle_log           UTL_FILE.FILE_TYPE;
  vr_nrcontad             PLS_INTEGER := 0;
  vr_setlinha             VARCHAR2(5000);
  vr_vet_campos           gene0002.typ_split;
  vr_des_erro             VARCHAR2(10000);
  vr_aux_cdcooper         NUMBER;
  vr_aux_nrdconta         NUMBER;
  vr_aux_idseqttl         NUMBER;
  vr_aux_vllimite         NUMBER;
  vr_cont_commit          NUMBER(6) := 0;
  vr_cont_commit_rollback NUMBER(6) := 0;
  vr_aux_ambiente         NUMBER(1) := 1;
  vr_nmarq_carga          VARCHAR2(5000);
  vr_nmarq_log            VARCHAR2(5000);
  vr_nmarq_rollback       VARCHAR2(5000);

  vr_aux_texto VARCHAR2(5000);

  TYPE typ_reg_carga IS RECORD(
    cdcooper         NUMBER,
    nrdconta         NUMBER,
    idseqttl         NUMBER,
    vllimite         NUMBER);

  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;

  CURSOR cr_rollback(pr_cdcooper IN NUMBER,
                     pr_nrdconta IN NUMBER,
                     pr_idseqttl IN NUMBER) IS
  
    SELECT snh.vllimweb
      FROM CECRED.crapsnh snh
     WHERE snh.nrdconta = pr_nrdconta
       AND snh.cdcooper = pr_cdcooper
       AND snh.idseqttl = pr_idseqttl
       AND tpdsenha = 1;
  rw_rollback cr_rollback%ROWTYPE;

BEGIN

  vr_nmarq_carga    := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0267395/' || 'RITM0267395_carga.csv';
  vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0267395/' || 'LOG.txt';
  vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0267395/' || 'RITM0267395_ROLLBACK.sql';

  GENE0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_carga,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_input_file,
                           pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao abrir o arquivo para leitura: ' ||
                   vr_nmarq_carga || ' - ' || vr_dscritic;
    RAISE vr_exc_erro;
  END IF;

  gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log,
                           pr_tipabert => 'W',
                           pr_utlfileh => vr_handle_log,
                           pr_des_erro => vr_des_erro);
  IF vr_des_erro IS NOT NULL THEN
    vr_dscritic := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
    RAISE vr_exc_erro;
  END IF;

  LOOP
    BEGIN
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file,
                                   pr_des_text => vr_setlinha);
    
      vr_nrcontad := vr_nrcontad + 1;
    
      vr_setlinha := REPLACE(REPLACE(REPLACE(vr_setlinha, chr(13), ''), chr(10), ''),'﻿','');
      vr_vet_campos := gene0002.fn_quebra_string(TRIM(vr_setlinha), ';');
    
      BEGIN
        vr_aux_cdcooper         := TO_NUMBER(vr_vet_campos(1));
        vr_aux_nrdconta         := TO_NUMBER(vr_vet_campos(2));
        vr_aux_idseqttl         := TO_NUMBER(vr_vet_campos(3));
        vr_aux_vllimite         := TO_NUMBER(vr_vet_campos(4));
      
      EXCEPTION
        WHEN OTHERS THEN
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                         pr_des_text => 'Erro na leitura da linha: ' ||
                                                        vr_nrcontad ||
                                                        ' => ' || SQLERRM);
        
          CONTINUE;
      END;
    
      vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
      vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;
      vr_tab_carga(vr_nrcontad).idseqttl := vr_aux_idseqttl;
      vr_tab_carga(vr_nrcontad).vllimite := vr_aux_vllimite;
    
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
      WHEN vr_exc_erro THEN
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na leitura da linha ' || vr_nrcontad || ' => ' ||
                       SQLERRM;
        RAISE vr_exc_erro;
    END;
  END LOOP;

  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                 pr_des_text => 'Coop;Conta;Titular;Valor_Limite_Web');

  gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback,
                           pr_tipabert => 'W',
                           pr_utlfileh => vr_handle,
                           pr_des_erro => vr_des_erro);
  IF vr_des_erro IS NOT NULL THEN
    vr_dscritic := 'Erro ao abrir arquivo de ROLLBACK: ' || vr_des_erro;
    RAISE vr_exc_erro;
  END IF;

  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                 pr_des_text => 'BEGIN');
                                 
  FOR vr_idx1 IN vr_tab_carga.first .. vr_tab_carga.last LOOP
    IF vr_tab_carga.exists(vr_idx1) THEN
    
      vr_cont_commit := vr_cont_commit + 1;
    
      OPEN cr_rollback(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper,
                       pr_nrdconta => vr_tab_carga(vr_idx1).nrdconta,
                       pr_idseqttl => vr_tab_carga(vr_idx1).idseqttl);
      FETCH cr_rollback
        INTO rw_rollback;
    
      IF cr_rollback%NOTFOUND THEN
        CLOSE cr_rollback;
      
      ELSE
      
        vr_aux_texto := '  UPDATE cecred.crapsnh SET vllimweb = ' ||
                        rw_rollback.vllimweb ||
                        ' WHERE cdcooper = ' || vr_tab_carga(vr_idx1).cdcooper ||
                        ' AND nrdconta = ' || vr_tab_carga(vr_idx1).nrdconta ||
                        ' AND idseqttl = ' || vr_tab_carga(vr_idx1).idseqttl ||
                        ' AND tpdsenha = 1;';
      
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                       pr_des_text => vr_aux_texto);
                     
    IF vr_cont_commit = 1000 THEN
      vr_aux_texto := 'COMMIT;';
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                       pr_des_text => vr_aux_texto);
      vr_aux_texto := '';
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                       pr_des_text => vr_aux_texto);
    END IF;
      
        CLOSE cr_rollback;
      END IF;
       
      UPDATE cecred.crapsnh
         SET vllimweb = vr_tab_carga(vr_idx1).vllimite
       WHERE cdcooper = vr_tab_carga(vr_idx1).cdcooper
         AND nrdconta = vr_tab_carga(vr_idx1).nrdconta
         AND idseqttl = vr_tab_carga(vr_idx1).idseqttl
         AND tpdsenha = 1;
    
      IF vr_cont_commit = 1000 THEN
        vr_cont_commit := 0;
        COMMIT;
      END IF;
    
    END IF;
  END LOOP;

  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                 pr_des_text => 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                 pr_des_text => 'END;');

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);

  COMMIT;

EXCEPTION

  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro arquivos: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                   pr_des_text => 'Erro arquivos: ' ||
                                                  vr_dscritic ||
                                                  ' SQLERRM: ' || SQLERRM);
  
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                   pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                   pr_des_text => 'Erro geral: ' ||
                                                  ' SQLERRM: ' || SQLERRM);
  
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                   pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
END;
/
