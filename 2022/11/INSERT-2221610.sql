BEGIN

  UPDATE cecred.crapepr
     SET vljrmprj = 0
        ,vljraprj = 0
        ,vlprejuz = 246.13
        ,vlsprjat = 246.13
        ,vlsdprej = 246.13
   WHERE cdcooper = 1 AND nrdconta = 89182391 AND nrctremp = 2221610;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
