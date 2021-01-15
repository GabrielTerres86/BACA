BEGIN

  UPDATE crapepr
     SET qtpreemp = 36
        ,vlpreemp = 193.72
  WHERE cdcooper = 1
    AND nrdconta = 9440291 
    AND nrctremp = 2328869;

  UPDATE tbepr_calculo_cet
     SET dsdprazo = '36 MESES'
        ,vlparemp = 193.72
  WHERE cdcooper = 1
    AND nrdconta = 9440291 
    AND nrctremp = 2328869;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
