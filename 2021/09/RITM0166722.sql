BEGIN
  UPDATE crapepr e
     SET e.vlsdeved = 62880.46
        ,e.vlsdevat = 62880.46
        ,e.qtmesdec = TRUNC(months_between(SYSDATE,e.dtmvtolt))
   WHERE e.cdcooper = 1 
     AND e.nrdconta = 2385651 
     AND e.nrctremp = 242195;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;