BEGIN

    UPDATE crappep
    SET    vlpagpar = 0
          ,vldstcor = 0
          ,vldstrem = 0
    WHERE  cdcooper = 1
    AND    nrdconta = 2772728
    AND    nrctremp = 2362968
    AND    nrparepr = 2;
    
    UPDATE crappep
    SET    vlpagpar = 0
          ,vldstcor = 0
          ,vldstrem = 0
    WHERE  cdcooper = 1
    AND    nrdconta = 6461328
    AND    nrctremp = 2219322
    AND    nrparepr = 2;
    
    UPDATE crappep
    SET    vlpagpar = 0
          ,vldstcor = 0
          ,vldstrem = 0
    WHERE  cdcooper = 1
    AND    nrdconta = 7780095
    AND    nrctremp = 2332598
    AND    nrparepr = 3;

  COMMIT;

EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;
