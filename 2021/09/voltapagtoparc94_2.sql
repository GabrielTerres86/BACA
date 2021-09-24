declare 

  vr_exc_saida     EXCEPTION;
 
  vr_cdcooper      crapcop.cdcooper%TYPE := 3;
  vr_nrdconta      crapass.nrdconta%TYPE := 94;
  vr_nrctremp      craplem.nrctremp%TYPE := 211409;

BEGIN

  BEGIN
    UPDATE crappep c
       SET vlparepr = 44500.74
          ,vlsdvpar = 44500.74
          ,vlsdvatu = 44500.74
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp
       and c.nrparepr = 6;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
