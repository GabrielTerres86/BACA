BEGIN

  UPDATE crapsab
     SET nmdsacad = 'ECO BLU CONFECOES LTDA'
   WHERE cdcooper = 1
     AND nrdconta = 11414200
     AND nrinssac = 2698350000107;

  UPDATE crapsab
     SET nmdsacad = 'CORE SC'
   WHERE cdcooper = 1
     AND nrdconta = 11414200
     AND nrinssac = 83896068000128;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    sistema.excecaoInterna(pr_compleme => 'INC0112642');
    ROLLBACK;
END;
