DECLARE
  p_caminho_arquivo VARCHAR2(2000);
  vr_nmdireto       VARCHAR2(2000);
  vr_nmarquiv       VARCHAR2(2000);
  v_arquivo         utl_file.file_type;
  v_linha           VARCHAR2(6000);
  vr_dscritic VARCHAR2(2000);
  conta       NUMBER := 0;
  contb       NUMBER := 0;
  vr_idmacica NUMBER;
  v_cdcooper  NUMBER;
  v_nrdconta  NUMBER;
  v_nrrecben  NUMBER;
  v_idseqttl  NUMBER;
  v_idseqrep  NUMBER;
  v_idbenefc  NUMBER;
  vr_idprglog NUMBER;
BEGIN
  vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                       pr_cdcooper => 3,
                                       pr_nmsubdir => '/log');
  vr_nmarquiv := '/beneficiarios.csv';

  p_caminho_arquivo := vr_nmdireto || vr_nmarquiv;

  gene0001.pc_abre_arquivo(pr_nmcaminh => p_caminho_arquivo,
                           pr_tipabert => 'R',
                           pr_utlfileh => v_arquivo,
                           pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    cecred.pc_log_programa(pr_cdcooper   => 3,
                           pr_cdprograma => 'INSS_BENEFICIO',
                           pr_dstiplog   => 'O',
                           pr_tpexecucao => 0,
                           pr_dsmensagem => 'OTHERS INSERT: ' || SQLERRM,
                           pr_idprglog   => vr_idprglog);
  ELSE
    LOOP
      gene0001.pc_le_linha_arquivo(pr_utlfileh => v_arquivo,
                                   pr_des_text => v_linha);
    
      IF instr(v_linha, '99FIM') > 0 THEN
        EXIT;
      END IF;
    
      v_cdcooper := to_number(substr(v_linha, 1, 2));
      v_nrdconta := to_number(substr(v_linha, 4, 20));
      v_nrrecben := to_number(substr(v_linha, 25, 20));
      v_idseqttl := to_number(substr(v_linha, 46, 3));
      v_idseqrep := to_number(substr(v_linha, 50, 3));
    
      BEGIN
        INSERT INTO convenios.tbinss_beneficio_cooperado
          (cdcooperativa,
           nrconta,
           nrbeneficio,
           nrbeneficiario,
           nrrepresentante_legal,
           cdsituacao)
        VALUES
          (v_cdcooper, v_nrdconta, v_nrrecben, v_idseqttl, v_idseqrep, 2)
        RETURNING idbeneficio_cooperado INTO v_idbenefc;
      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL;
        WHEN OTHERS THEN
          cecred.pc_log_programa(pr_cdcooper   => 3,
                                 pr_cdprograma => 'INSS_BENEFICIO',
                                 pr_dstiplog   => 'O',
                                 pr_tpexecucao => 0,
                                 pr_dsmensagem => 'OTHERS INSERT: ' || SQLERRM,
                                 pr_idprglog   => vr_idprglog);
      END;
    
      BEGIN
        INSERT INTO convenios.tbinss_beneficio_evento
          (idbeneficio_cooperado, dsevento)
        VALUES
          (v_idbenefc, 'Inclusão de registro via carga de dados.');
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      conta := conta + 1;
      contb := contb + 1;
    
      IF contb >= 2500 THEN
        COMMIT;
        contb := 0;
      END IF;
    
      IF conta >= 500000 THEN
        EXIT;
      END IF;
    END LOOP;
  END IF;

  COMMIT;

  IF utl_file.is_open(v_arquivo) THEN
    gene0001.pc_fecha_arquivo(v_arquivo);
  END IF;
EXCEPTION
  WHEN no_data_found THEN
    ROLLBACK;
    cecred.pc_log_programa(pr_cdcooper   => 3,
                           pr_cdprograma => 'INSS_BENEFICIO',
                           pr_dstiplog   => 'O',
                           pr_tpexecucao => 0,
                           pr_dsmensagem => 'no_data_found: ' || SQLERRM,
                           pr_idprglog   => vr_idprglog);
    IF utl_file.is_open(v_arquivo) THEN
      gene0001.pc_fecha_arquivo(v_arquivo);
    END IF;
  WHEN OTHERS THEN
    ROLLBACK;
    cecred.pc_log_programa(pr_cdcooper   => 3,
                           pr_cdprograma => 'INSS_BENEFICIO',
                           pr_dstiplog   => 'O',
                           pr_tpexecucao => 0,
                           pr_dsmensagem => 'OTHERS: ' || SQLERRM,
                           pr_idprglog   => vr_idprglog);
    IF utl_file.is_open(v_arquivo) THEN
      gene0001.pc_fecha_arquivo(v_arquivo);
    END IF;
END;
