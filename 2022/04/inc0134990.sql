BEGIN
  
  UPDATE tbcobran_devolucao dev
     SET dtmvtolt = TO_DATE('18/04/2022', 'DD/MM/YYYY')
   WHERE dev.cdcooper = 1
     AND dev.dtmvtolt = TO_DATE('12/04/2022', 'DD/MM/YYYY');
  
  IF SQL%ROWCOUNT = 12 THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 1, pr_compleme => 'INC0134990');
    ROLLBACK;
END;
