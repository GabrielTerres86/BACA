BEGIN 
  UPDATE crapepr
     SET qtprepag = 2,
         qtprecal = 2
   WHERE nrctremp = 2901329
     AND cdcooper = 1
     AND nrdconta = 10452265;
     
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
