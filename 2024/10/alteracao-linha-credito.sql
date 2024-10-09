declare
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'/cpd/bacas/BACA-ALTERACAO-LINHA';
  vr_nmarqimp        VARCHAR2(100)  := 'alteracaolinha.csv';
  vr_nmarqimpr       VARCHAR2(100)  := 'ROLLBACK_alteracaolinha.csv';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquivr     utl_file.file_type;  
  vr_linha           varchar2(5000);
  vr_campo           GENE0002.typ_split;
  vr_texto_padrao    VARCHAR2(200);     
  vr_cdcooper        crapepr.cdcooper%type; 
  vr_nrdconta        crapepr.nrdconta%type; 
  vr_nrctremp        crapepr.nrctremp%type;
  vr_cdlcremp        crapepr.cdlcremp%type;
  vr_cdlcremp_old    crapepr.cdlcremp%type;  
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
  gene0001.pc_escr_linha_arquivo(vr_ind_arquivr,'COOP;CONTA;CONTRATO;RESULTADO;OBSERVACAO');
  
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
      vr_cdlcremp_old := NULL;
      
      vr_cdcooper := GENE0002.fn_char_para_number(vr_campo(1));
      vr_nrdconta := GENE0002.fn_char_para_number(vr_campo(2));
      vr_nrctremp := GENE0002.fn_char_para_number(vr_campo(3));
      vr_cdlcremp := GENE0002.fn_char_para_number(vr_campo(4));
      
      
      vr_texto_padrao := vr_cdcooper || ';' ||
                         vr_nrdconta || ';' ||
                         vr_nrctremp || ';' ||
                         vr_cdlcremp || ';';
      BEGIN                   
        SELECT cdlcremp
          INTO vr_cdlcremp_old                         
          FROM crapepr epr
         WHERE epr.cdcooper = vr_cdcooper
           AND epr.nrdconta = vr_nrdconta
           AND epr.nrctremp = vr_nrctremp;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao || 'NOK;Coop, Conta, Contrato não encontrado.');
          CONTINUE;
      END;
                                                                                    
     UPDATE crapepr epr 
        SET epr.cdlcremp = vr_cdlcremp
      WHERE epr.cdcooper = vr_cdcooper
        AND epr.nrdconta = vr_nrdconta
        AND epr.nrctremp = vr_nrctremp;
        
      vr_texto_padrao := vr_texto_padrao || 'OK;'
                                         || ' UPDATE crapepr epr '
                                         || '    SET epr.cdlcremp = ' || vr_cdlcremp_old
                                         || '  WHERE epr.cdcooper = ' || vr_cdcooper
                                         || '    AND epr.nrdconta = ' || vr_nrdconta
                                         || '    AND epr.nrctremp = ' || vr_nrctremp ||';';
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquivr, vr_texto_padrao);
      
      IF vr_cont  = 50 THEN
         vr_cont := 0;
      COMMIT;   
      END IF;  
     
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
