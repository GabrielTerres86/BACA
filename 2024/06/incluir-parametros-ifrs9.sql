DECLARE
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/PRJ0025225-PARAMETRO';
  vr_nmarqimp        VARCHAR2(100)  := 'DEPARATOPAZPARAMETRO.csv';
  vr_nmarqimpr       VARCHAR2(100)  := 'ERROS_DEPARATOPAZPARAMETRO.csv';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquivr     utl_file.file_type;  
  vr_linha           varchar2(5000);
  vr_campo           GENE0002.typ_split;
  vr_texto_padrao    VARCHAR2(200); 
      
  vr_cdconvivencia   credito.tbcred_integracao_parametro.cdconvivencia%TYPE;
  vr_nmproduto       credito.tbcred_integracao_parametro.nmproduto_convivencia%TYPE;
  vr_cdacao          credito.tbcred_integracao_parametro.cdacao%TYPE;
  vr_cdfila          credito.tbcred_integracao_parametro.cdfila%TYPE;
  vr_nrope           credito.tbcred_integracao_parametro.nrope%TYPE;
  vr_payload         credito.tbcred_integracao_parametro.dspayload%TYPE;
   
  vr_cont            NUMBER(6) := 0;
  vr_cdcritic        crapcri.cdcritic%TYPE;
  vr_dscritic        VARCHAR2(32767);
  vr_exc_saida       EXCEPTION;
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
  gene0001.pc_escr_linha_arquivo(vr_ind_arquivr,'CODIGO;OBSERVACAO');
  
  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,
                               pr_des_text => vr_linha);
                               
  BEGIN        
    DELETE FROM credito.tbcred_integracao_parametro;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      vr_dscritic := 'Erro ao deletar tabela de parametro';         
  END;  
                                
  LOOP
      BEGIN
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,pr_des_text => vr_linha);
        EXCEPTION
           WHEN no_data_found THEN 
              EXIT;
      END;
      
      vr_cont  := vr_cont+1;
      vr_campo := GENE0002.fn_quebra_string(pr_string => vr_linha, pr_delimit => ';');
            
      vr_cdconvivencia := GENE0002.fn_char_para_number(vr_campo(1));
      vr_nmproduto     := vr_campo(2);
      vr_cdacao        := vr_campo(3);
      vr_cdfila        := vr_campo(4);
      vr_nrope         := GENE0002.fn_char_para_number(vr_campo(5));
      vr_payload       := vr_campo(6);
      
      vr_texto_padrao := vr_cdconvivencia || ';' ||
                         vr_nmproduto || ';';      
      
      BEGIN        
        INSERT INTO credito.tbcred_integracao_parametro (cdconvivencia,
                                                         nmproduto_convivencia,
                                                         cdacao,
                                                         cdfila,
                                                         nrope,
                                                         dspayload)
        VALUES(vr_cdconvivencia,
               vr_nmproduto,    
               vr_cdacao,       
               vr_cdfila,       
               vr_nrope,        
               vr_payload);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir linha: '||vr_cont||' | Produto: '||vr_cdconvivencia;         
      END;                                                                                                                                                          
     
      IF vr_dscritic IS NOT NULL THEN
        gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao || 'NOK;' || vr_dscritic);
        CONTINUE;
      END IF;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao || 'OK;');
      
      IF vr_cont  = 10 THEN
         vr_cont := 0;
      COMMIT;   
      END IF;  
     
   END LOOP;
   gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivr); 
   COMMIT;
   
EXCEPTION 
  WHEN OTHERS THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivr); 
    ROLLBACK;
END;
