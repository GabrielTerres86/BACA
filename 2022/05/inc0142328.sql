BEGIN

  UPDATE tbcobran_devolucao dev
     SET dtmvtolt = TO_DATE('17/05/2022', 'DD/MM/YYYY')
   WHERE dtmvtolt = '13/05/2022'
     AND cdcooper IN (7, 9, 1);

  IF SQL%ROWCOUNT = 7 THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0142328');
    ROLLBACK;
END;