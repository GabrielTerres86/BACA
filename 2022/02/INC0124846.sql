DECLARE
   
   vr_ind_arquiv           utl_file.file_type;   
   vr_rootmicros           VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
   vr_nmdireto             VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0120603';
   vr_nmarqimp             VARCHAR2(100)  := 'backup_inc0124846.txt';
   vr_dscritic             VARCHAR2(5000) := ' ';
   
   CURSOR cr_craprac is
      SELECT distinct
            (SELECT sum(l.vllanmto) 
               FROM craplac l
              WHERE l.cdhistor in(3527,3229,3532)
                AND l.cdcooper = lac.cdcooper
                AND l.nrdconta = lac.nrdconta
                AND l.nraplica = lac.nraplica ) vl_credito,
            (SELECT SUM(l.vllanmto) 
               FROM craplac l
              WHERE l.cdhistor in (3528)
                AND l.cdcooper = lac.cdcooper
                AND l.nrdconta = lac.nrdconta
                AND l.nraplica = lac.nraplica ) vl_debito
            ,rac.idsaqtot
            ,rac.nrdconta
            ,rac.nraplica 
            ,rac.cdcooper     
        FROM craprac rac,
             craplac lac
       WHERE rac.cdcooper = lac.cdcooper
         AND rac.nrdconta = lac.nrdconta
         AND rac.nraplica = lac.nraplica
         AND lac.dtmvtolt >= to_date('01/02/2022','dd/mm/yyyy')
         AND lac.cdcooper in(1,16) 
         AND lac.vllanmto is not null 
         AND rac.cdprodut = 1109
         AND rac.idsaqtot = 1;
       
         
   rw_craprac cr_craprac%ROWTYPE;     
   
   PROCEDURE backup (pr_msg VARCHAR2) IS
   BEGIN
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, pr_msg);
   END; 
         
BEGIN
  
   gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto       
                          ,pr_nmarquiv => vr_nmarqimp       
                          ,pr_tipabert => 'W'               
                          ,pr_utlfileh => vr_ind_arquiv     
                          ,pr_des_erro => vr_dscritic); 
  
   FOR rw_craprac IN cr_craprac LOOP
      IF rw_craprac.vl_credito <> rw_craprac.vl_debito THEN
         BACKUP('UPDATE CRAPRAC SET IDSAQTOT = 1 WHERE NRDCONTA = '||rw_craprac.nrdconta||' AND NRAPLICA = '||rw_craprac.nraplica||' AND CDCOOPER = '||rw_craprac.cdcooper||';');          
         UPDATE craprac 
            SET idsaqtot = 0 
          WHERE nrdconta = rw_craprac.nrdconta 
            AND nraplica = rw_craprac.nraplica
            AND cdcooper = rw_craprac.cdcooper;

      END IF;
   END LOOP;
   
   COMMIT;
   gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
   
   EXCEPTION 
      WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20001,'Ocorreu um erro ao atualizar o registro. '||sqlerrm);
END;         
  


   
   
   

  
  
  
 

 
 

 
 


 






