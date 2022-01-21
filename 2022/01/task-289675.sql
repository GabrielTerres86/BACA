DECLARE
   vr_excsaida    EXCEPTION;
   vr_dscritic    VARCHAR2(5000) := ' ';
   vr_nraplica    craprac.nraplica%TYPE;
   vr_nmarqimp1   VARCHAR2(100)  := 'backup.txt';
   vr_ind_arquiv1 utl_file.file_type;   
   vr_rootmicros  VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
   vr_nmdireto    VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0120603';  
   
   CURSOR cr_craprac IS
     SELECT rac.cdcooper, 
            rac.nrdconta, 
            rac.nraplica, 
            rac.dtaniver, 
            rac.cdprodut,
            rac.dtmvtolt           
       FROM craprac rac
      WHERE rac.dtaniver = to_date('01/02/2022','dd/mm/yyyy') --Aniversário errado
        AND rac.dtmvtolt >= to_date('29/11/2021','dd/mm/yyyy') AND rac.dtmvtolt <= to_date('30/11/2021','dd/mm/yyyy') -- Data de movimento do aporte        
        AND rac.cdcooper in (1, 16) -- cooperativas Viacredi e Alto Vale        
        AND rac.idsaqtot = 0 -- Saque parcial.        
        AND rac.cdprodut = 1109; -- Produto poupança
   
        rw_craprac cr_craprac%ROWTYPE;
   
   PROCEDURE backup (pr_msg VARCHAR2) IS
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
   
  FOR rw_craprac in cr_craprac LOOP
    BACKUP('UPDATE CRAPRAC SET DTANIVER = ''01/02/2022'' WHERE CDCOOPER = '||rw_craprac.cdcooper ||' AND '||' NRDCONTA = '||rw_craprac.nrdconta||' AND NRAPLICA = '||rw_craprac.nraplica||';');
    
    UPDATE craprac craprac 
       SET craprac.dtaniver = to_date('01/01/2022','dd/mm/yyyy') 
     WHERE craprac.cdcooper = rw_craprac.cdcooper
       AND craprac.nrdconta = rw_craprac.nrdconta
       AND craprac.nraplica = rw_craprac.nraplica;

  END LOOP;
    
  COMMIT;
  
  fecha_arquivos;
  
  EXCEPTION 
     WHEN vr_excsaida then  
         backup('ERRO ' || vr_dscritic);  
         fecha_arquivos;  
         ROLLBACK;    
     WHEN OTHERS then
         vr_dscritic :=  sqlerrm;
         backup('ERRO ' || vr_dscritic); 
         fecha_arquivos; 
         ROLLBACK; 

END;
