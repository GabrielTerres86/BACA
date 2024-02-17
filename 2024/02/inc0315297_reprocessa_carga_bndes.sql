
UPDATE cecred.tbrecup_acordo_contrato c
   SET c.INRISCO_ACORDO = 2
 WHERE c.NRACORDO = 490076 
   AND c.NRCTREMP = 2562456;
/
COMMIT;
/
DELETE gestaoderisco.tbrisco_central_carga t
WHERE t.IDCENTRAL_CARGA = 34125;
/
COMMIT;
/
DECLARE   

  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(4000);
  
  
BEGIN 

  GESTAODERISCO.geraCargaCentral(pr_cdcooper => 1
                                ,pr_flgbndes => TRUE
                                ,pr_dtrefere => to_date('16/02/2024','DD/MM/RRRR')
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

  IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20500,'Erro:'||vr_dscritic);
  END IF;  
                                
END;