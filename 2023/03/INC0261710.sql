DECLARE
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0261710_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0261710_script_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0261710_relatorio_exec.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arquiv2        utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  Cursor vc_telefone is
    SELECT *
      FROM CECRED.CRAPTFC TFC
     WHERE TFC.NRDDDTFC = 0
        OR TFC.NRTELEFO = 0;
      
  vr_telefone vc_telefone%rowtype;
  
  
  vr_nrdrowid       ROWID;
  vr_dscritic       VARCHAR2(2000);
  vr_mesref         VARCHAR2(10);
  vr_dtmvtolt       DATE := SISTEMA.datascooperativa(3).dtmvtolt;
  vr_exception      EXCEPTION;
  
  vr_contador      integer;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0261710';
  
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
  

  vr_contador := 0;
  FOR vr_telefone IN vc_telefone LOOP
    
    BEGIN
      
      vr_contador := vr_contador + 1;
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' insert into CECRED.craptfc (CDCOOPER, NRDCONTA, IDSEQTTL, CDSEQTFC, CDOPETFN, NRDDDTFC, TPTELEFO, NMPESCTO, PRGQFALT, NRTELEFO, NRDRAMAL, PROGRESS_RECID, IDSITTFC, IDORIGEM, FLGACSMS, DTINSORI, DTREFATU, INPRINCIPAL, INWHATSAPP)
         values (' || vr_telefone.cdcooper    ||',' ||
                      vr_telefone.nrdconta    ||',' || 
                      vr_telefone.idseqttl    ||',' ||
                      vr_telefone.cdseqtfc    ||',' ||
                      vr_telefone.CDOPETFN    ||',' ||
                      vr_telefone.NRDDDTFC    ||',' ||
                      vr_telefone.TPTELEFO    ||',''' ||
                      vr_telefone.NMPESCTO    ||''',''' ||
                      vr_telefone.PRGQFALT    ||''',' ||                                            
                      vr_telefone.NRTELEFO    ||',' ||  
                      vr_telefone.NRDRAMAL    ||',' ||                                             
                      vr_telefone.PROGRESS_RECID ||',' ||                        
                      vr_telefone.IDSITTFC    ||',' ||                        
                      vr_telefone.IDORIGEM    ||',' ||                        
                      vr_telefone.FLGACSMS    ||', to_date(''' ||                        
                      vr_telefone.DTINSORI    ||''',''dd/mm/yyyy''), to_date( ''' ||                        
                      vr_telefone.DTREFATU    ||''',''dd/mm/yyyy''),' ||                    
                      nvl(to_char(vr_telefone.INPRINCIPAL),'NULL') ||',' ||                        
                      nvl(to_char(vr_telefone.INWHATSAPP), 'NULL') || ');');                   
                      
                      
                         
      DELETE 
        FROM CECRED.CRAPTFC
       WHERE CDCOOPER = VR_TELEFONE.CDCOOPER
         AND NRDCONTA = VR_TELEFONE.NRDCONTA;
         
      If vr_contador = 500 then
         vr_contador := 0;
         commit;
      end if;
         
      
    EXCEPTION       
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir telefone ' || SQLERRM;
        RAISE vr_exception;
    END;
    
  END LOOP;
  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
