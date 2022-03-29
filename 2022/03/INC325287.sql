DECLARE 
    
    vr_excsaida    EXCEPTION;
    vr_dscritic    VARCHAR2(5000) := ' ';
    vr_nraplica    craprac.nraplica%TYPE;
    vr_nmarqimp1   VARCHAR2(100)  := 'backup_inc325287.txt';
    vr_ind_arquiv1 utl_file.file_type;   
    vr_rootmicros  VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto    VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/inc114752'; 
    vr_dtcdcoop1   DATE;
    vr_dtcdcoop16  DATE;
    CURSOR cr_crapdat is
       SELECT cdcooper,
              dtmvtolt 
         FROM crapdat
        WHERE cdcooper IN (1,16);
        rw_crapdat cr_crapdat%ROWTYPE; 
    
    CURSOR cr_craprac is
       SELECT 16 cdcooper, 
              107824 nrdconta, 
              9 nraplica,  
              306.06 vllanmto            
         FROM dual
        
        UNION ALL
       
       SELECT 16 cdcooper, 
              129321 nrdconta, 
              28 nraplica,  
              14.24 vllanmto            
         FROM dual
         
        UNION ALL
       
       SELECT 1 cdcooper, 
              2061090 nrdconta, 
              8 nraplica,  
              19.96 vllanmto            
         FROM dual 
         
        UNION ALL
         
       SELECT 1 cdcooper, 
              2592851 nrdconta, 
              195 nraplica,  
              2.86 vllanmto            
         FROM dual 
        
        UNION ALL
       
       SELECT 1 cdcooper, 
              3849856 nrdconta, 
              23 nraplica,  
              29.32 vllanmto            
         FROM dual 
       
        UNION ALL
       
       SELECT 1 cdcooper, 
              7490909 nrdconta, 
              53 nraplica,  
              0.30 vllanmto            
         FROM dual
        
        UNION ALL
        
       SELECT 1 cdcooper, 
              8488037 nrdconta, 
              43 nraplica,  
              230.75 vllanmto            
         FROM dual 
        
        UNION ALL
        
       SELECT 1 cdcooper, 
              8754837 nrdconta, 
              95 nraplica,  
              8.82 vllanmto            
         FROM dual
        
        UNION ALL 
        
       SELECT 1 cdcooper, 
              8868433 nrdconta, 
              11 nraplica,  
              2.18 vllanmto            
         FROM dual 
         
        UNION ALL
        
       SELECT 1 cdcooper, 
              10291598 nrdconta, 
              37 nraplica,  
              6.82 vllanmto            
         FROM dual   
         
        UNION ALL
       
       SELECT 1 cdcooper, 
              10470794 nrdconta, 
              39 nraplica,  
              6.81 vllanmto            
         FROM dual
         
        UNION ALL
       
       SELECT 1 cdcooper, 
              11349115 nrdconta, 
              10 nraplica,  
              2.84 vllanmto            
         FROM dual
       
        UNION ALL
       
       SELECT 1 cdcooper, 
              12268127 nrdconta, 
              3 nraplica,  
              3.85 vllanmto            
         FROM dual  
         
        UNION ALL
       
       SELECT 1 cdcooper, 
              12651966 nrdconta, 
              8 nraplica,  
              3.98 vllanmto            
         FROM dual  
         
        UNION ALL
       
       SELECT 1 cdcooper, 
              13240625 nrdconta, 
              1 nraplica,  
              0.31 vllanmto            
         FROM dual
         
        UNION ALL
       
       SELECT 1 cdcooper, 
              13596578 nrdconta, 
              4 nraplica,  
              5.49 vllanmto            
         FROM dual 
        
        UNION ALL
       
       SELECT 1 cdcooper, 
              13864882 nrdconta, 
              4 nraplica,  
              2.55 vllanmto            
         FROM dual;       
       rw_craprac cr_craprac%ROWTYPE;
        
    CURSOR cr_backup(pcdcooper number
                    ,pnrdconta number
                    ,pnraplica number) is
       SELECT rac.cdcooper,
              rac.nrdconta,
              rac.nraplica,
              rac.dtatlsld,
              replace(rac.vlsldatl,',','.') vlsldatl,
              replace(rac.vlsldant,',','.') vlsldant, 
              rac.dtsldant
         FROM craprac rac
        WHERE rac.cdcooper = pcdcooper
          AND rac.nrdconta = pnrdconta
          AND rac.nraplica = pnraplica;
       rw_backup cr_backup%ROWTYPE;
       
    PROCEDURE backup_arquivo (pr_msg VARCHAR2) IS
    BEGIN
       gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
    END; 
  
    PROCEDURE fecha_arquivo IS
    BEGIN
       gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
    END;                                
    
BEGIN
   
   BEGIN 
     
      BEGIN
          gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto      
                                ,pr_nmarquiv => vr_nmarqimp1       
                                ,pr_tipabert => 'W'                
                                ,pr_utlfileh => vr_ind_arquiv1     
                                ,pr_des_erro => vr_dscritic);      
         IF vr_dscritic IS NOT NULL THEN 
            RAISE vr_excsaida; 
         END IF;
      END;
      
      FOR rw_crapdat IN cr_crapdat LOOP
         
         IF rw_crapdat.cdcooper = 1 THEN
            vr_dtcdcoop1 := rw_crapdat.dtmvtolt;
         ELSE
            vr_dtcdcoop16 := rw_crapdat.dtmvtolt; 
         END IF;
      
      END LOOP;
      FOR rw_craprac IN cr_craprac LOOP
                     
              FOR rw_backup in cr_backup(rw_craprac.cdcooper,rw_craprac.nrdconta, rw_craprac.nraplica) LOOP
                  
                  backup_arquivo('UPDATE craprac SET dtatlsld ='||''''||rw_backup.dtatlsld||''''||',vlsldatl ='||rw_backup.vlsldatl||',vlsldant ='||rw_backup.vlsldant||',dtsldant ='||''''||rw_backup.dtsldant||''''||' WHERE nrdconta ='||rw_backup.nrdconta||' AND nraplica ='||rw_backup.nraplica||' AND cdcooper ='||rw_backup.cdcooper||';');                           
              
              END LOOP;
              
              BEGIN     
                
                  UPDATE craprac 
                     SET dtatlsld = decode(rw_craprac.cdcooper,1,vr_dtcdcoop1,16,vr_dtcdcoop16)
                        ,vlsldatl = rw_craprac.vllanmto                        
                        ,vlsldant = vlsldatl
                        ,dtsldant = dtatlsld
                  WHERE nrdconta = rw_craprac.nrdconta
                    AND nraplica = rw_craprac.nraplica
                    AND cdcooper = rw_craprac.cdcooper;
              
              EXCEPTION 
                  WHEN OTHERS THEN
                     RAISE_APPLICATION_ERROR('-20000','Ocorreu um problema ao atualizar o registro da craprac.'||SQLERRM);      
                    
              END;
      END LOOP;
   
   EXCEPTION 
       WHEN OTHERS THEN
          ROLLBACK;
          RAISE_APPLICATION_ERROR('-20001','Ocorreu um erro ao executar a rotina de atualização.'||SQLERRM);       
   
   END;  
   
   fecha_arquivo;
   
   COMMIT;
           
END;
