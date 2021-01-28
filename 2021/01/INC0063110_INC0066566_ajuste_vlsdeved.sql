BEGIN

  UPDATE crapepr epr
     SET epr.vlsdeved = 16761.43
   WHERE epr.cdcooper = 12
     AND epr.nrdconta = 40703
     AND epr.nrctremp = 21704;

  UPDATE crapepr epr
     SET epr.vlsdeved = 277331.98
   WHERE epr.cdcooper = 1
     AND epr.nrdconta = 8668957
     AND epr.nrctremp = 1916169;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
      
END;