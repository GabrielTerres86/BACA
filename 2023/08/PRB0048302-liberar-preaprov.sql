declare
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'/cpd/bacas/PRB0048302';
  vr_nmarqimp        VARCHAR2(100)  := 'PRB0048302.csv';
  vr_nmarqimpr       VARCHAR2(100)  := 'ROLLBACK_PRB0048302.csv';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquivr     utl_file.file_type;  
  vr_linha           varchar2(5000);
  vr_campo           GENE0002.typ_split;
  vr_texto_padrao    VARCHAR2(200);     
  vr_cdcooper        crapepr.cdcooper%type; 
  vr_nrdconta        crapepr.nrdconta%type; 
  vr_cont            NUMBER(6) := 0;
  vr_cdcritic        crapcri.cdcritic%TYPE;
  vr_dscritic        VARCHAR2(32767);
  vr_exc_saida       EXCEPTION;
  vr_nrdrowid        ROWID;
  
     
  CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ass.nrcpfcnpj_base
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;   
  
BEGIN
    
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        
                          ,pr_nmarquiv => vr_nmarqimp       
                          ,pr_tipabert => 'R'                
                          ,pr_utlfileh => vr_ind_arquiv     
                          ,pr_des_erro => vr_dscritic);     
  IF vr_dscritic IS NOT NULL THEN  
    dbms_output.put_line(vr_dscritic);    
    RAISE vr_exc_saida;
  END IF;   
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        
                          ,pr_nmarquiv => vr_nmarqimpr       
                          ,pr_tipabert => 'W'                
                          ,pr_utlfileh => vr_ind_arquivr     
                          ,pr_des_erro => vr_dscritic);     
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;
  gene0001.pc_escr_linha_arquivo(vr_ind_arquivr,'COOP;CONTA;RESULTADO;OBSERVACAO');
  
  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,
                               pr_des_text => vr_linha);
  LOOP
      BEGIN
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,pr_des_text => vr_linha);
        EXCEPTION
           WHEN no_data_found THEN 
              EXIT;
      END;
      
      vr_cont  := vr_cont+1;
      vr_campo := GENE0002.fn_quebra_string(pr_string => vr_linha, pr_delimit => ';');
      
      vr_cdcooper := GENE0002.fn_char_para_number(vr_campo(1));
      vr_nrdconta := GENE0002.fn_char_para_number(vr_campo(2));
      
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => vr_nrdconta);
        FETCH cr_crapass
        INTO rw_crapass;     
      IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := gene0001.fn_busca_critica(9);  
          RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      BEGIN
        DELETE FROM cecred.TBCC_PARAM_PESSOA_PRODUTO a
        WHERE a.cdproduto = 25
        AND   a.nrdconta > 0
        AND   a.nrcpfcnpj_base = rw_crapass.nrcpfcnpj_base;  
      END;
      
      vr_texto_padrao := vr_cdcooper || ';' ||
                         vr_nrdconta || ';';
                         
      cada0006.pc_mantem_param_pessoa_prod(pr_cdcooper           => vr_cdcooper
                                          ,pr_nrdconta           => vr_nrdconta
                                          ,pr_cdproduto          => 25
                                          ,pr_cdoperac_produto   => 1 
                                          ,pr_flglibera          => 1
                                          ,pr_dtvigencia_paramet => NULL
                                          ,pr_idmotivo           => 19
                                          ,pr_cdoperad           => 1
                                          ,pr_idorigem           => 5
                                          ,pr_nmdatela           => 'TELA_ATENDA_PREAPV'
                                          ,pr_dscritic           => vr_dscritic);                                                                                          
     
      IF vr_dscritic IS NOT NULL THEN
        gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao || 'NOK;' || vr_dscritic);
        CONTINUE;
      END IF;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao || 'OK;'); 
      
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => 1
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                          ,pr_dstransa => 'Desbloqueio manual de Pre Aprovado - PRB0048302'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 0
                          ,pr_nmdatela => 'TELA_ATENDA_PREAPV'
                          ,pr_nrdconta => vr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);        
     
   END LOOP;
   gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivr); 
   COMMIT;
   
EXCEPTION 
  WHEN OTHERS THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivr); 
    dbms_output.put_line(sqlerrm);
    dbms_output.put_line(sqlcode);
    ROLLBACK;
END;
