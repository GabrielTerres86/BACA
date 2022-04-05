declare 

  vr_cdcooper      crapcop.cdcooper%TYPE := 9;
  vr_nrdconta      crapass.nrdconta%TYPE := 321737;
  vr_nrctremp      craplem.nrctremp%TYPE := 35607;

BEGIN

    UPDATE crapepr c
       SET diarefju = 14
     WHERE c.cdcooper = vr_cdcooper
       AND c.nrdconta = vr_nrdconta
       AND c.nrctremp = vr_nrctremp;

  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
