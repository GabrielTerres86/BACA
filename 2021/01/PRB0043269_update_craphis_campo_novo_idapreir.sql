BEGIN
  UPDATE CECRED.CRAPHIS
     SET IDAPREIR = 1
   WHERE CDHISTOR IN (108,
                      2332,
                      2333,
                      275,
                      92,
                      384,
                      1706,
                      317,
                      1539,
                      2336,
                      2337,
                      394,
                      1715,
                      2370,
                      2372,
                      2374,
                      2376,
                      2386,
                      2387);
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
