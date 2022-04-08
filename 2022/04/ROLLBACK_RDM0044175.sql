BEGIN

    DELETE FROM craplem l 
     WHERE l.cdcooper = 1
       AND l.nrdconta = 10379339
       AND l.nrctremp = 4320638 
       AND l.nrdolote = 600031
       AND l.cdhistor = 1041
       AND l.vllanmto = 68.28;

    DELETE FROM craplem l 
     WHERE l.cdcooper = 1
       AND l.nrdconta = 10379339 
       AND l.nrctremp = 4320638 
       AND l.nrdolote = 600031
       AND l.cdhistor = 1705
       AND l.vllanmto = 269.07;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
