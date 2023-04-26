DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarqbkp           VARCHAR2(50) := 'INC0265495_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0265495_log_execucao.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_total        PLS_INTEGER;
    
 
  
  CURSOR cr_crapenc IS
      SELECT ASS.CDCOOPER, ASS.NRDCONTA, ENC2.IDSEQTTL, ENC2.TPENDASS, ENC2.CDSEQINC, ENC2.DSENDERE, ENC2.PROGRESS_RECID
      FROM CRAPASS ASS
         , CRAPENC ENC2
     WHERE ASS.INPESSOA = 1
       AND ENC2.CDCOOPER = ASS.CDCOOPER
       AND ENC2.NRDCONTA = ASS.NRDCONTA
       AND NOT EXISTS ( SELECT 1
                          FROM CRAPENC ENC
                         WHERE ENC.CDCOOPER = ASS.CDCOOPER
                           AND ENC.NRDCONTA = ASS.NRDCONTA 
                           AND ENC.CDSEQINC = 1 )
     ORDER BY 1, 2, 5 ;
  
  rg_crapenc  cr_crapenc%ROWTYPE;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_sequencial  Integer := 0;
  vr_coop        Integer := 0;
  vr_conta       Integer := 0;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0265495';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  
  vr_count := 0;
  vr_count_total := 0;

  
  OPEN cr_crapenc;
  
  LOOP
    FETCH cr_crapenc INTO rg_crapenc;
    EXIT WHEN cr_crapenc%NOTFOUND;
    
    BEGIN
      
      If vr_coop  != rg_crapenc.cdcooper OR
         vr_conta != rg_crapenc.nrdconta THEN
         
         vr_sequencial := 1;
         vr_coop  := rg_crapenc.cdcooper;
         vr_conta := rg_crapenc.nrdconta;
       Else
         vr_sequencial := vr_sequencial + 1;
      End if;
      
      UPDATE CECRED.crapenc e
         SET e.cdseqinc = vr_sequencial
       WHERE e.progress_recid = rg_crapenc.progress_recid;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    UPDATE CECRED.crapenc SET  '
                                                      || ' cdseqinc = '''    || rg_crapenc.cdseqinc || ''' '
                                                      || 'WHERE progress_recid = ' || rg_crapenc.progress_recid || '; ' );
      vr_count := vr_count + 1;
      vr_count_total := vr_count_total + 1;
      
      IF vr_count >= 50 THEN
        
        vr_count := 0;
        COMMIT;
        
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        
        CLOSE cr_crapenc;
        vr_dscritic := 'Erro ao atualizar endereço: ' || SQLERRM;
        RAISE vr_exception;
        
    END;
    
  END LOOP;
  
  CLOSE cr_crapenc;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script - SUCESSO. ' || vr_count_total || ' registros atualizados com sucesso.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'Erro na execução do script: ' || vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script. ERRO: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Total de ' || vr_count_total || ' registros encontrados até o erro.');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'Erro na execução do script: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script. ERRO: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Total de ' || vr_count_total || ' registros encontrados até o erro.');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20001, 'ERRO GERAL: ' || SQLERRM);
END;
