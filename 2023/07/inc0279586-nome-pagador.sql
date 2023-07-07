BEGIN

  UPDATE crapsab
     SET nmdsacad = 'CONDOMINIO VILLE DE FRANCE RESIDENCE'
   WHERE cdcooper = 1
     AND nrdconta = 10775943
     AND nrinssac = 76706456000133;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    sistema.excecaoInterna(pr_compleme => 'INC0279586');
    ROLLBACK;
END;
