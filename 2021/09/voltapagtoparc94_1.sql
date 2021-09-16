declare 

  vr_exc_saida     EXCEPTION;
 
  vr_cdcooper      crapcop.cdcooper%TYPE := 3;
  vr_nrdconta      crapass.nrdconta%TYPE := 94;
  vr_nrctremp      craplem.nrctremp%TYPE := 211409;

BEGIN
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = 731322.09 
          ,vlsdvpar = 731322.09 
          ,vlsdvatu = 731322.09 
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr >= 13 
       and c.inliquid = 0;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
