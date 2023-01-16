BEGIN
  UPDATE CECRED.crapceb c
     SET c.insitceb = 2
   WHERE c.cdcooper = 7
     AND c.nrdconta = 99889412
     AND c.nrconven = 106002;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0239630');
    ROLLBACK;
END;
