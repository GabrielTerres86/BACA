DECLARE
  
  CURSOR cr_crapdat is
     SELECT dtmvtolt 
       FROM crapdat
      WHERE cdcooper = 1;
        
  CURSOR cr_craprac is       
     SELECT 1 cdcooper, 
            9167161 nrdconta, 
            77 nraplica,  
            12695.48 vllanmto, 
            200000.00 vlsldatl         
       FROM dual 
      UNION ALL
     SELECT 1 cdcooper, 
            9167161 nrdconta, 
            78 nraplica,   
            34517.20 vllanmto, 
            350000.00 vlsldatl
       FROM dual;

    rw_craprac cr_craprac%ROWTYPE;
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;   
    pr_cdcooper craprac.cdcooper%TYPE;
    vr_nrseqdig craplot.nrseqdig%TYPE;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida EXCEPTION;
  
BEGIN
     
     OPEN cr_crapdat;
    FETCH cr_crapdat into vr_dtmvtolt;
    CLOSE cr_crapdat;

     FOR rw_craprac IN cr_craprac LOOP 
          
          APLI0010.pc_processa_lote_aniv(pr_cdcooper => rw_craprac.cdcooper
                                        ,pr_dtmvtolt => vr_dtmvtolt
                                        ,pr_cdagenci => 1
                                        ,pr_cdbccxlt => 100
                                        ,pr_nrdolote => 558506
                                        ,pr_cdoperad => '1'
                                        ,pr_vllanmto => rw_craprac.vllanmto
                                        ,pr_vllanneg => rw_craprac.vllanmto
                                        ,pr_nrseqdig => vr_nrseqdig
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
             IF vr_cdcritic <> 0 THEN
                vr_dscritic := 'Erro criando lote - ' || nvl(vr_dscritic,' ');
                RAISE vr_exc_saida;       
             END IF; 
             
             BEGIN
                 INSERT INTO craplac(cdcooper
                                    ,dtmvtolt
                                    ,cdagenci
                                    ,cdbccxlt
                                    ,nrdolote
                                    ,nrdconta
                                    ,nraplica
                                    ,nrdocmto
                                    ,nrseqdig
                                    ,vllanmto
                                    ,cdhistor)
                             VALUES( rw_craprac.cdcooper
                                    ,vr_dtmvtolt
                                    ,1 
                                    ,100 
                                    ,558506 
                                    ,rw_craprac.nrdconta
                                    ,rw_craprac.nraplica
                                    ,vr_nrseqdig
                                    ,vr_nrseqdig
                                    ,rw_craprac.vllanmto
                                    ,3328); 
                                    
             EXCEPTION 
                WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20000,'Ocorreu um erro ao inserir o registro na tabela craplac. '||SQLERRM);
             END;     
                                
             BEGIN
                 UPDATE craprac 
                    SET dtatlsld = vr_dtmvtolt
                       ,vlsldatl = rw_craprac.vlsldatl + rw_craprac.vllanmto                        
                       ,vlsldant = vlsldatl
                       ,dtsldant = dtatlsld
                  WHERE nrdconta = rw_craprac.nrdconta
                    AND nraplica = rw_craprac.nraplica
                    AND cdcooper = rw_craprac.cdcooper;  
                     
             EXCEPTION 
                WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20000,'Ocorreu um erro ao atualizar o registro na tabela craprac. '||SQLERRM);                
             END;       
         
                                                                                          
   END LOOP; 
   
   COMMIT;
   
   EXCEPTION 
     WHEN OTHERS THEN
        ROLLBACK;
   
END;
