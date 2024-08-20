DECLARE
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/PRJ0025225-LINHAS';
  vr_nmarqimp        VARCHAR2(100)  := 'PRJ0025225-LINHAS.csv';
  vr_nmarqimpr       VARCHAR2(100)  := 'ERROS_PRJ0025225-LINHAS.csv';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquivr     utl_file.file_type;  
  vr_linha           varchar2(5000);
  vr_campo           GENE0002.typ_split;
  vr_texto_padrao    VARCHAR2(200); 
      
  vr_cdcooper         cecred.craplcr.cdcooper%TYPE;
  vr_cdlcremp         cecred.craplcr.cdlcremp%TYPE;
  vr_prodmigracao     cecred.craplcr.cdmigracao%TYPE;
  vr_prodconvivencia  cecred.craplcr.cdconvivencia%TYPE;
   
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
   UPDATE cecred.craplcr a 
   SET a.tppessoa = CASE 
                      WHEN a.cdmodali = 02 and a.cdsubmod IN (02,03,11) THEN 1
                        WHEN a.cdmodali = 02 and a.cdsubmod IN (05,06,15,16,17) THEN 2
                          ELSE 0
                            END,
       a.cdconvivencia = NULL,
       a.cdmigracao = NULL;                     
                             
  COMMIT;
  EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     vr_dscritic := 'Erro ao atulizar tipo de pessoa na craplcr';         
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
            
      vr_cdcooper         := GENE0002.fn_char_para_number(vr_campo(1));
      vr_cdlcremp         := GENE0002.fn_char_para_number(vr_campo(2));
      vr_prodmigracao     := GENE0002.fn_char_para_number(vr_campo(3));
      vr_prodconvivencia  := GENE0002.fn_char_para_number(vr_campo(4));
      
      vr_texto_padrao := vr_cdcooper || ';' ||
                         vr_cdlcremp || ';';      
      
      BEGIN        
        UPDATE cecred.craplcr a 
        SET a.cdmigracao = vr_prodmigracao,
            a.cdconvivencia = vr_prodconvivencia
        WHERE a.cdcooper = vr_cdcooper
          AND a.cdlcremp = vr_cdlcremp;                   
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        vr_dscritic := 'Erro ao atualizar Linha convivencia';         
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
