DECLARE
  vr_rootmicros           VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto             VARCHAR2(4000) := vr_rootmicros || '/cpd/bacas/INC0293424';
  vr_nmarqimp             VARCHAR2(100)  := 'INC0293424_operacoes.csv';
  vr_nmarqimp_rollback    VARCHAR2(100)  := 'INC0293424_operacoes_ROLLBACK.sql';
  vr_nmarqimp_faltantes   VARCHAR2(100)  := 'INC0293424_operacoes_NOTFOUND.csv';
  vr_nmarqimp_log         VARCHAR2(100)  := 'INC0293424_operacoes_LOG.txt';
  vr_ind_arquiv           utl_file.file_type;
  vr_ind_arquiv_rollback  utl_file.file_type;
  vr_ind_arquiv_faltantes utl_file.file_type;
  vr_ind_arquiv_log       utl_file.file_type;
  vr_linha                VARCHAR2(5000);
  vr_campo                GENE0002.typ_split;

  vr_texto_padrao         VARCHAR2(800);
  vr_nrctremp             crapepr.nrctremp%TYPE;

  TYPE typ_tab_idexterno  IS TABLE OF NUMBER INDEX BY VARCHAR2(15);

  vr_tab_idexterno        typ_tab_idexterno;
  vr_tab_encontrado       typ_tab_idexterno;

  CURSOR cr_crapepr IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.cdfinemp
          ,epr.cdlcremp
          ,peac.idpeac_contrato
      FROM crapepr epr,
           credito.tbcred_peac_contrato peac
     WHERE epr.cdlcremp IN (4600, 5600, 508)
       AND epr.cdcooper = peac.cdcooper (+)
       AND epr.nrdconta = peac.nrdconta (+)
       AND epr.nrctremp = peac.nrcontrato (+);

  rw_crapepr cr_crapepr%ROWTYPE;
  idx VARCHAR2(15);

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_des_reto VARCHAR(3);
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_dscritic VARCHAR2(32767);
  vr_exc_saida       EXCEPTION;

BEGIN
  dbms_output.enable(NULL);

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                           pr_nmarquiv => vr_nmarqimp,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_ind_arquiv,
                           pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;


  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                           pr_nmarquiv => vr_nmarqimp_rollback,
                           pr_tipabert => 'W',
                           pr_utlfileh => vr_ind_arquiv_rollback,
                           pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                          pr_nmarquiv  => vr_nmarqimp_faltantes,
                          pr_tipabert  => 'W',
                          pr_utlfileh  => vr_ind_arquiv_faltantes,
                          pr_des_erro  => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                          pr_nmarquiv  => vr_nmarqimp_log,
                          pr_tipabert  => 'W',
                          pr_utlfileh  => vr_ind_arquiv_log,
                          pr_des_erro  => vr_dscritic);

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
  
    vr_nrctremp := GENE0002.fn_char_para_number(vr_campo(1));
  
    vr_tab_idexterno(vr_nrctremp) := vr_nrctremp;
  
  END LOOP;

  FOR rw_crapepr IN cr_crapepr LOOP
    
    vr_tab_encontrado(rw_crapepr.nrctremp) := rw_crapepr.nrctremp;
    
    IF vr_tab_idexterno.EXISTS(rw_crapepr.nrctremp) AND NVL(rw_crapepr.idpeac_contrato, 0) = 0 THEN
      
      BEGIN
        INSERT INTO credito.tbcred_peac_contrato
          (cdcooper
          ,nrdconta
          ,nrcontrato
          ,idcontratoexterno)
        VALUES
          (rw_crapepr.cdcooper
          ,rw_crapepr.nrdconta
          ,rw_crapepr.nrctremp
          ,rw_crapepr.nrctremp);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := SQLCODE;
          vr_dscritic := 'Erro ao inserir na tabela credito.tbcred_peac_contrato | Cooperativa: ' ||
                         rw_crapepr.cdcooper || ' Conta: ' ||
                         rw_crapepr.nrdconta || ' Contrato: ' ||
                         rw_crapepr.nrctremp || ' ' || SQLERRM;
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv_log, vr_dscritic);
      END;
    
      vr_texto_padrao := 'DELETE FROM credito.tbcred_peac_contrato WHERE cdcooper = ' ||
                         rw_crapepr.cdcooper || ' AND nrdconta = ' ||
                         rw_crapepr.nrdconta || ' AND nrcontrato = ' ||
                         rw_crapepr.nrctremp || ';';
    
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv_rollback, vr_texto_padrao);
    END IF;
  END LOOP;

  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv_faltantes, 'idcontratoexterno');

  idx := vr_tab_idexterno.FIRST;
  WHILE idx IS NOT NULL LOOP
    IF NOT vr_tab_encontrado.EXISTS(idx) THEN
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv_faltantes, vr_tab_idexterno(idx));
    END IF;
    idx := vr_tab_idexterno.NEXT(idx);
  END LOOP;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_rollback);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_faltantes);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_log);

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_rollback);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_faltantes);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_log);
    RAISE_APPLICATION_ERROR(-20501, 'Erro ao abrir arquivo para importacao ' || vr_dscritic);
  WHEN OTHERS THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_rollback);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_faltantes);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_log);
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20502, SQLERRM);
END;