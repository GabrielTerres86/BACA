DECLARE

BEGIN

  UPDATE CECRED.CRAPEPR epr
     SET dtliquid =
         (SELECT max(dtmvtolt)
            FROM CECRED.craplem lem
           WHERE epr.cdcooper = lem.cdcooper
             and epr.nrdconta = lem.nrdconta
             AND epr.nrctremp = lem.nrctremp)
   WHERE ((nrctremp in (20205, 44129, 181564) and cdcooper = 13) or
         (nrctremp = 38918 and cdcooper = 10));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
