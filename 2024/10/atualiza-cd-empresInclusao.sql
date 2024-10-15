BEGIN

  FOR x IN (SELECT ep.cdcooper
                  ,ep.nrdconta
                  ,ep.nrctremp
                  ,ep.cdempres
              FROM cecred.crapepr ep
             WHERE ep.cdempres > 0
               AND ep.cdempres_inclusao = 0) LOOP
  
    BEGIN
      UPDATE cecred.crapepr ep
         SET ep.cdempres_inclusao = x.cdempres
       WHERE ep.cdcooper = x.cdcooper
         AND ep.nrdconta = x.nrdconta
         AND ep.nrctremp = x.nrctremp;
    
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
    END;
  
    COMMIT;
  
  END LOOP;

END;
