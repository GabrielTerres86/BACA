BEGIN
  
UPDATE CECRED.CRAPLCR 
   SET flgsegpr = 1,
       tpcuspr = 1
 WHERE cdcooper in (1, 9, 13) 
   AND (cdlcremp IN(1, 2, 3, 4, 5, 6, 7, 1079, 1541, 1645) OR
        cdlcremp IN (SELECT DISTINCT cdlcrhab 
                       FROM craplch l 
                      WHERE l.cdfinemp IN (57, 230, 6901, 100, 800, 900) AND cdcooper IN (1, 9, 13)
                     )
       );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
/
