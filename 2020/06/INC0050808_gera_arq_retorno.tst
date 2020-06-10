PL/SQL Developer Test script 3.0
35
-- Created on 08/06/2020 by F0030344 
DECLARE  

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  
 CURSOR cr_crapcop IS
   SELECT *
     FROM crapcop c
    WHERE c.flgativo = 1
      AND c.cdcooper IN (1,2,7,9,11,16);
    
BEGIN 
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
    PGTA0001.pc_gera_retorno_tit_pago(pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_dtmvtolt => TO_DATE('29/05/2020','DD/MM/RRRR') --TO_DATE('29/05/2020','DD/MM/RRRR')
                                     ,pr_idorigem => 3
                                     ,pr_cdoperad => '1'
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                                 
    PGTA0001.pc_gera_retorno_tit_pago(pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_dtmvtolt => TO_DATE('01/06/2020','DD/MM/RRRR')
                                     ,pr_idorigem => 3
                                     ,pr_cdoperad => '1'
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                                     
  END LOOP;
  
  
  COMMIT;
END;
0
0
