DECLARE 
   vr_nmarqimp1            VARCHAR2(100)  := 'backup.txt';
   vr_ind_arquiv1          utl_file.file_type;   
   vr_rootmicros           VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
   vr_nmdireto             VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/RITM0199878'; 
   vr_dscritic             VARCHAR2(4000);
   vr_excsaida             EXCEPTION;
        
   PROCEDURE pc_backup (pr_msg VARCHAR2) IS
   BEGIN
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
   END; 
  
   PROCEDURE fecha_arquivos IS
   BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
   END;
   
BEGIN
  
   gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto       
                          ,pr_nmarquiv => vr_nmarqimp1      
                          ,pr_tipabert => 'W'               
                          ,pr_utlfileh => vr_ind_arquiv1    
                          ,pr_des_erro => vr_dscritic);     
  
  
  IF vr_dscritic IS NOT NULL THEN             
     RAISE vr_excsaida;
  END IF;
  
  pc_backup('update crapprm set dsvlrprm = ''D'' where nmsistem = ''CRED'' and cdcooper = 13 and cdacesso = ''LIMITE_APLIC_PLANO_COTAS'';');
  pc_backup('update crapprm set dsvlrprm = ''D'' where nmsistem = ''CRED'' and cdcooper = 9 and cdacesso = ''LIMITE_APLIC_PLANO_COTAS'';');
  
  BEGIN
    
    UPDATE crapprm prm SET dsvlrprm = 'C'
     WHERE prm.nmsistem = 'CRED'
       AND prm.cdcooper = 13 
       AND prm.cdacesso = 'LIMITE_APLIC_PLANO_COTAS'; 

    UPDATE crapprm prm SET dsvlrprm = 'C'
     WHERE prm.nmsistem = 'CRED'
       AND prm.cdcooper = 9
       AND prm.cdacesso = 'LIMITE_APLIC_PLANO_COTAS';        
       
  EXCEPTION 
    WHEN OTHERS THEN 
      vr_dscritic := 'Erro ao fazer update na crapprm. ' || SQLERRM ;
      RAISE vr_excsaida;
  END; 
    
  COMMIT;      
  
  fecha_arquivos;                                  
  
EXCEPTION  
  WHEN vr_excsaida then  
       pc_backup('ERRO ' || vr_dscritic);  
       fecha_arquivos;  
       ROLLBACK;    
  WHEN OTHERS then
       vr_dscritic :=  sqlerrm;
       pc_backup('ERRO ' || vr_dscritic); 
       fecha_arquivos; 
       ROLLBACK; 
              
END;

