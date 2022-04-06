declare
  --variaveis dos arquivo arquivos
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'/cpd/bacas/inc0129428';
  vr_nmarqimp        VARCHAR2(100)  := 'diff_consig_fev_1.csv';
  vr_nmarqimpr       VARCHAR2(100)  := 'log_diff_consig_fev_1.csv';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquivr     utl_file.file_type;  
  vr_linha           varchar2(5000);
  vr_campo           GENE0002.typ_split;

  --variaveis para o programa
  rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;
  vr_texto_padrao    VARCHAR2(200);     
  vr_cdcooper        crapepr.cdcooper%type;  
  vr_nrdconta        crapepr.nrdconta%type;
  vr_nrctremp        crapepr.nrctremp%type;
  vr_lanctoaj        crapepr.vlsdevat%type;
  vr_cdhistor        craplem.cdhistor%type;
  vr_cdagenci        craplem.cdagenci%type;
  vr_vlpreemp        craplem.vlpreemp%type;
  vr_txjuremp        craplem.txjurepr%TYPE;

  --variaveis de exception
  vr_cdcritic        crapcri.cdcritic%TYPE;
  vr_des_reto        varchar(3);
  vr_tab_erro        GENE0001.typ_tab_erro;
  vr_dscritic        VARCHAR2(32767);
  vr_exc_saida       EXCEPTION;

BEGIN

  -- Com base na data da central
  OPEN  btch0001.cr_crapdat(pr_cdcooper => 3);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;  

  -- Abre arquivo de ajuste
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'R'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro

  IF vr_dscritic IS NOT NULL THEN  
    dbms_output.put_line( vr_dscritic);    
    RAISE vr_exc_saida;
  END IF;   

  --Abre arquivo de RollBack
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimpr       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquivr     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro

  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;

  gene0001.pc_escr_linha_arquivo(vr_ind_arquivr,'COOP;CONTA;CONTRATO;HISTORICO;AGENCIA;VALOR;RESULTADO;OBSERVACAO');
  
  /*leitura do cabeçalho*/
  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,pr_des_text => vr_linha);

  LOOP
      BEGIN
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,pr_des_text => vr_linha);
        EXCEPTION
           WHEN no_data_found THEN 
              EXIT;
      END;
      
      vr_campo := GENE0002.fn_quebra_string(pr_string => vr_linha, pr_delimit => ';');

      vr_cdcooper := GENE0002.fn_char_para_number(vr_campo(1));
      vr_nrdconta := GENE0002.fn_char_para_number(vr_campo(2));
      vr_nrctremp := GENE0002.fn_char_para_number(vr_campo(3));
      vr_cdhistor := GENE0002.fn_char_para_number(vr_campo(4));
      vr_cdagenci := GENE0002.fn_char_para_number(vr_campo(5));
      vr_vlpreemp := GENE0002.fn_char_para_number(vr_campo(6));
      vr_txjuremp := GENE0002.fn_char_para_number(vr_campo(7));
      vr_lanctoaj := GENE0002.fn_char_para_number(vr_campo(8));
      

      vr_texto_padrao := vr_cdcooper || ';' ||
                         vr_nrdconta || ';' ||
                         vr_nrctremp || ';' ||
                         vr_cdhistor || ';' ||
                         vr_cdagenci || ';' ||
                         vr_lanctoaj || ';';
                                               
      empr0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_cdagenci => vr_cdagenci
                                      ,pr_cdbccxlt => 100 
                                      ,pr_cdoperad => 1 
                                      ,pr_cdpactra => vr_cdagenci
                                      ,pr_tplotmov => 5 
                                      ,pr_nrdolote => 600013
                                      ,pr_nrdconta => vr_nrdconta
                                      ,pr_cdhistor => vr_cdhistor 
                                      ,pr_nrctremp => vr_nrctremp
                                      ,pr_vllanmto => vr_lanctoaj  
                                      ,pr_dtpagemp => rw_crapdat.dtmvtolt 
                                      ,pr_txjurepr => vr_txjuremp
                                      ,pr_vlpreemp => vr_vlpreemp
                                      ,pr_nrsequni => 0 
                                      ,pr_nrparepr => 0 
                                      ,pr_flgincre => TRUE 
                                      ,pr_flgcredi => TRUE 
                                      ,pr_nrseqava => 0 
                                      ,pr_cdorigem => 7 
                                      ,pr_cdcritic => vr_cdcritic 
                                      ,pr_dscritic => vr_dscritic);
     
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao || 'NOK;' || vr_dscritic);
        CONTINUE;
      END IF;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao || 'OK;');
     
   END LOOP;

   gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivr); 
   --COMMIT;
   
EXCEPTION 
  WHEN OTHERS THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivr); 
    dbms_output.put_line( sqlerrm);
    dbms_output.put_line( sqlcode);
    ROLLBACK;
END;
