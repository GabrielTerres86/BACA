BEGIN
  BEGIN
    UPDATE crapcyb cyb
       SET cyb.dtdbaixa = NULL
     WHERE EXISTS (SELECT 1
              FROM crapepr epr
             WHERE cyb.cdcooper = epr.cdcooper
               AND cyb.nrdconta = epr.nrdconta
               AND cyb.nrctremp = epr.nrctremp
               AND cyb.vlsdprej > 0
               AND cyb.dtdbaixa IS NOT NULL);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Falha update crapcyb ' || SQLERRM);
  END;

  COMMIT;
END;
