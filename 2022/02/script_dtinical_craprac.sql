declare 
   vr_nmarqimp1            VARCHAR2(100)  := 'backup.txt';
   vr_ind_arquiv1          utl_file.file_type;   
   vr_rootmicros           VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
   vr_nmdireto             VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/prb0046751';        
   vr_dscritic             VARCHAR2(4000);
   vr_excsaida             EXCEPTION;
     
   CURSOR cr_craprac IS
     SELECT r.*,r.rowid FROM craprac r
      WHERE r.cdprodut = 1057
        AND r.idsaqtot = 0;
   rw_craprac cr_craprac%ROWTYPE;
        
   PROCEDURE pc_backup (pr_msg VARCHAR2) IS
   BEGIN
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
   END; 
  
   PROCEDURE fecha_arquivos IS
   BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
   END;
   
BEGIN
  
   -- Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro  
  
  -- Em caso de crítica
  IF vr_dscritic IS NOT NULL THEN             
     RAISE vr_excsaida;
  END IF;
  
  FOR rw_craprac IN cr_craprac LOOP
      pc_backup('update craprac set dtinical = null where cdcooper = ' || rw_craprac.cdcooper ||
                                                    ' and nrdconta = ' || rw_craprac.nrdconta ||
                                                    ' and nraplica = ' || rw_craprac.nraplica || ' ;');
      
      BEGIN
        UPDATE craprac SET dtinical = add_months(rw_craprac.dtaniver,-1)
         WHERE ROWID = rw_craprac.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao fazer update na craprac. ' || SQLERRM || ' . cdcooper: ' || rw_craprac.cdcooper || ' nrdconta: ' || rw_craprac.nrdconta || ' nraplica: ' || rw_craprac.nraplica;     
          RAISE vr_excsaida;
      END;  
                                                          
  END LOOP;
  
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
  
end;

