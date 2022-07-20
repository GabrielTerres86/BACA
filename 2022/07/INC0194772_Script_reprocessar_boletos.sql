BEGIN

  UPDATE crapcob cob
     SET cob.inenvcip = 1
   WHERE (cob.cdcooper, cob.nrdconta) IN ((13, 850004))
     AND cob.dtmvtolt >= to_date('13072022', 'ddmmyyyy')
     AND cob.dtmvtolt < to_date('21072022', 'ddmmyyyy')
     AND cob.inenvcip = 0
     AND cob.incobran = 0
     AND cob.dtvencto >= trunc(SYSDATE);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0194772');
    ROLLBACK;
END;
