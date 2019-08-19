PL/SQL Developer Test script 3.0
33
-- Created on 14/02/2019 by T0031667 
declare 
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(2000);
  
begin
  -- Test statements here
  --77585
  --152102
    --Cancelamento Limite de Credito
   LIMI0002.pc_cancela_limite_credito(pr_cdcooper   => 7             
                                       ,pr_cdagenci   => 0           
                                       ,pr_nrdcaixa   => 0           
                                       ,pr_cdoperad   => '1'         
                                       ,pr_nrdconta   => 77585       
                                       ,pr_nrctrlim   => 342448
                                       ,pr_inadimp    => 1                  
                                       ,pr_cdcritic   => vr_cdcritic        
                                       ,pr_dscritic   => vr_dscritic);   
                                       
    --Cancelamento Limite de Credito
   LIMI0002.pc_cancela_limite_credito(pr_cdcooper   => 7             
                                       ,pr_cdagenci   => 0           
                                       ,pr_nrdcaixa   => 0           
                                       ,pr_cdoperad   => '1'         
                                       ,pr_nrdconta   => 152102       
                                       ,pr_nrctrlim   => 390047
                                       ,pr_inadimp    => 1                  
                                       ,pr_cdcritic   => vr_cdcritic        
                                       ,pr_dscritic   => vr_dscritic);  
                                       
  COMMIT;                                       
end;
2
vr_cdcritic
0
5
vr_dscritic
0
5
0
