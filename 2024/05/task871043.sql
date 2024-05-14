BEGIN

  UPDATE crawepr a
     SET a.insitapr = 1
        ,a.insitest = 3
		,a.dtaprova = TRUNC(SYSDATE)
   WHERE a.cdcooper = 1
     AND a.nrdconta = 81304366
     AND a.nrctremp = 8149399;

  COMMIT;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;


