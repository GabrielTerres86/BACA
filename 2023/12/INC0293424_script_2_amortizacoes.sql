DECLARE
  vr_rootmicros           VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto             VARCHAR2(4000) := vr_rootmicros || '/cpd/bacas/INC0293424';
  vr_nmarqimp             VARCHAR2(100)  := 'INC0293424_amortizacoes.csv';
  vr_nmarqimp_rollback    VARCHAR2(100)  := 'INC0293424_amortizacoes_ROLLBACK.sql';
  vr_nmarqimp_log         VARCHAR2(100)  := 'INC0293424_amortizacoes_LOG.txt';
  vr_ind_arquiv           utl_file.file_type;
  vr_ind_arquiv_rollback  utl_file.file_type;
  vr_ind_arquiv_log       utl_file.file_type;
  vr_linha                VARCHAR2(5000);
  vr_campo                GENE0002.typ_split;

  vr_texto_padrao VARCHAR2(800);

  TYPE typ_reg_dados_parcelas IS RECORD (
    idcontratoexterno credito.tbcred_peac_contrato.idcontratoexterno%TYPE,
    dtamortizacao credito.tbcred_peac_contrato_parcela.dtamortizacao%TYPE,
    vlamortizacao credito.tbcred_peac_contrato_parcela.vlamortizacao%TYPE,
    nrparcela     credito.tbcred_peac_contrato_parcela.nrparcela%TYPE
  );

  TYPE typ_tab_parcelas IS TABLE OF typ_reg_dados_parcelas INDEX BY PLS_INTEGER;
  vr_tab_parcelas     typ_tab_parcelas;

  vr_idcontratoexterno       credito.tbcred_peac_contrato.idcontratoexterno%TYPE;
  vr_idcontratoexterno_atual credito.tbcred_peac_contrato.idcontratoexterno%TYPE;
  vr_dtamortizacao           credito.tbcred_peac_contrato_parcela.dtamortizacao%TYPE;
  vr_vlamortizacao           credito.tbcred_peac_contrato_parcela.vlamortizacao%TYPE;
  vr_nrparcela               credito.tbcred_peac_contrato_parcela.nrparcela%TYPE;
  
  idx_parcela              PLS_INTEGER := 0;
  idx                      PLS_INTEGER;

  vr_idpeac_contrato       credito.tbcred_peac_contrato.idpeac_contrato%TYPE;

  CURSOR cr_contrato_parcela (pr_idcontratoexterno IN credito.tbcred_peac_contrato.idcontratoexterno%TYPE) IS
    SELECT ctr.idpeac_contrato,
           ctr.idcontratoexterno
      FROM credito.tbcred_peac_contrato ctr
    WHERE ctr.idcontratoexterno = pr_idcontratoexterno
      AND NOT EXISTS
      (SELECT *
          FROM credito.tbcred_peac_contrato_parcela par
        WHERE ctr.idpeac_contrato = par.idpeac_contrato);

  rw_contrato_parcela cr_contrato_parcela%ROWTYPE;

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_des_reto VARCHAR(3);
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_dscritic VARCHAR2(32767);
  vr_exc_saida       EXCEPTION;
  vr_exc_dml_peac EXCEPTION;

BEGIN

  dbms_output.enable(NULL);
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                           pr_nmarquiv => vr_nmarqimp,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_ind_arquiv,
                           pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    dbms_output.put_line(vr_dscritic);
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
                           pr_nmarquiv => vr_nmarqimp_log,
                           pr_tipabert => 'W',
                           pr_utlfileh => vr_ind_arquiv_log,
                           pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;  

  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv, pr_des_text => vr_linha);

  LOOP
    BEGIN
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,
                                   pr_des_text => vr_linha);
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;
  
    vr_campo := GENE0002.fn_quebra_string(pr_string  => vr_linha, pr_delimit => ';');

    vr_idcontratoexterno_atual := GENE0002.fn_char_para_number(vr_campo(1));

    IF vr_idcontratoexterno_atual <> NVL(vr_idcontratoexterno,0) THEN
      vr_nrparcela := 1;
    ELSE
      vr_nrparcela := vr_nrparcela + 1;
    END IF;

    vr_idcontratoexterno := GENE0002.fn_char_para_number(vr_campo(1));   
    vr_dtamortizacao     := vr_campo(2);
    vr_vlamortizacao     := GENE0002.fn_char_para_number(vr_campo(3));

    idx_parcela := idx_parcela + 1;
  
    vr_tab_parcelas(idx_parcela).idcontratoexterno := vr_idcontratoexterno;
    vr_tab_parcelas(idx_parcela).dtamortizacao     := vr_dtamortizacao;
    vr_tab_parcelas(idx_parcela).vlamortizacao     := vr_vlamortizacao;
    vr_tab_parcelas(idx_parcela).nrparcela         := vr_nrparcela;
  
  END LOOP;

  BEGIN
    DELETE FROM credito.tbcred_peac_contrato_parcela;
  EXCEPTION
    WHEN OTHERS THEN
      vr_cdcritic := SQLCODE;
      vr_dscritic := 'Erro ao excluir da tabela credito.tbcred_peac_contrato_parcela' ||  SQLERRM;
      RAISE vr_exc_dml_peac;
  END;


  idx := vr_tab_parcelas.FIRST;
  WHILE idx IS NOT NULL LOOP

    IF vr_tab_parcelas(idx).nrparcela = 1 THEN
      OPEN cr_contrato_parcela (pr_idcontratoexterno => vr_tab_parcelas(idx).idcontratoexterno);  
      FETCH cr_contrato_parcela INTO rw_contrato_parcela;

      IF cr_contrato_parcela%FOUND THEN
        vr_idpeac_contrato := rw_contrato_parcela.idpeac_contrato;
        vr_texto_padrao := 'DELETE FROM credito.tbcred_peac_contrato_parcela WHERE idpeac_contrato = ' || rw_contrato_parcela.idpeac_contrato || ';';
      
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv_rollback, vr_texto_padrao);

      ELSE
        vr_idpeac_contrato := NULL;
      END IF;

      CLOSE cr_contrato_parcela;
    END IF;

    IF NVL(vr_idpeac_contrato,0) <> 0 THEN
      BEGIN
        INSERT INTO credito.tbcred_peac_contrato_parcela
          (idpeac_contrato
          ,nrparcela
          ,dtamortizacao
          ,vlamortizacao)
        VALUES
          (vr_idpeac_contrato
          ,vr_tab_parcelas(idx).nrparcela
          ,vr_tab_parcelas(idx).dtamortizacao
          ,vr_tab_parcelas(idx).vlamortizacao);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela credito.tbcred_peac_contrato_parcela' ||
                         'idpeac_contrato: ' || vr_idpeac_contrato ||
                         'nrparcela: '       || vr_tab_parcelas(idx).nrparcela ||
                         'dtamortizacao: '   || to_char(vr_tab_parcelas(idx).dtamortizacao, 'dd/mm/rrrr') ||
                         'vlamortizacao: '   || vr_tab_parcelas(idx).vlamortizacao ||
                         ' ' || SQLERRM;
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv_log, vr_dscritic);
      END;
    END IF;

    idx := vr_tab_parcelas.NEXT(idx);

  END LOOP;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_rollback);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_log);

  COMMIT;

EXCEPTION
  WHEN vr_exc_dml_peac THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_rollback);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_log);
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20500, vr_dscritic);
  WHEN vr_exc_saida THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_rollback);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_log);
    RAISE_APPLICATION_ERROR(-20501, 'Erro ao abrir arquivo para importacao ' || vr_dscritic);
  WHEN OTHERS THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_rollback);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv_log);
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20502, SQLERRM);
END;