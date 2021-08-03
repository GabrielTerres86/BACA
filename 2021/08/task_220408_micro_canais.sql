BEGIN
 DELETE FROM crapepr w 
       WHERE w.nrdconta = 2687100
         AND w.nrctremp = 3843033
         AND w.cdcooper = 1;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;         
END;
