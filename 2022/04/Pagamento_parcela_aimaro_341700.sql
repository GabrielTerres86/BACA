DECLARE
  v_cdcooper crappep.cdcooper%TYPE := 10;
  v_nrdconta crappep.nrdconta%TYPE := 51187;  
  v_nrctremp crappep.nrctremp%TYPE := 21960;
  v_nrparepr crappep.nrparepr%TYPE := 12;
BEGIN
  BEGIN
    UPDATE crappep
       SET vlsdvpar = 0, vlsdvatu = 0, inliquid = 1, vlpagpar = 144.49
     WHERE cdcooper = v_cdcooper
       AND nrdconta = v_nrdconta
       AND nrctremp = v_nrctremp
       AND nrparepr = v_nrparepr;
  
    COMMIT;  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20500, SQLERRM);
      ROLLBACK;
  END;
END;
