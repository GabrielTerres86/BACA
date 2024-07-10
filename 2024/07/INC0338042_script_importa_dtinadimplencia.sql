DECLARE
  vr_rootmicros           VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto             VARCHAR2(4000) := vr_rootmicros || '/cpd/bacas/INC0338042';
  vr_nmarqimp             VARCHAR2(100)  := 'INC0338042_operacoes.csv';
  vr_ind_arquiv           utl_file.file_type;
  vr_linha                VARCHAR2(5000);
  vr_campo                GENE0002.typ_split;

  vr_texto_padrao           VARCHAR2(800);
  vr_idcontrato             credito.tbcred_pronampe_contrato.idcontrato%TYPE;
  vr_dtinicio_inadimplencia credito.tbcred_pronampe_contrato.dtinicio_inadimplencia%TYPE;

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_des_reto VARCHAR(3);
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_dscritic VARCHAR2(32767);
  vr_exc_saida       EXCEPTION;

BEGIN

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                           pr_nmarquiv => vr_nmarqimp,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_ind_arquiv,
                           pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv, pr_des_text => vr_linha);

  LOOP
    BEGIN
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv, pr_des_text => vr_linha);
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;
  
    vr_campo := GENE0002.fn_quebra_string(pr_string  => vr_linha, pr_delimit => ';');

    vr_idcontrato             := GENE0002.fn_char_para_number(vr_campo(1));
    vr_dtinicio_inadimplencia := to_date(vr_campo(2), 'dd/mm/rrrr');

    IF vr_dtinicio_inadimplencia IS NOT NULL THEN
      BEGIN
        UPDATE credito.tbcred_pronampe_contrato SET dtinicio_inadimplencia = vr_dtinicio_inadimplencia WHERE idcontrato = vr_idcontrato;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;    
  
  END LOOP;
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    RAISE_APPLICATION_ERROR(-20501, 'Erro ao abrir arquivo para importacao ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    RAISE_APPLICATION_ERROR(-20502, SQLERRM);
END;