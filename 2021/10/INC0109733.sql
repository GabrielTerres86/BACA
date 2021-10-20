BEGIN

  DELETE FROM craplem t
        WHERE t.cdcooper = 1
          AND t.nrdconta = 2192063 
          AND t.nrctremp = 3469892 
          AND t.dtmvtolt = to_date('13/08/2021','dd/mm/yyyy');

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
