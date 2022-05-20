BEGIN

  UPDATE cecred.tbcobran_devolucao dev
     SET dtmvtolt = TO_DATE('19/05/2022', 'DD/MM/YYYY')
   WHERE dtmvtolt = TO_DATE('16/05/2022', 'DD/MM/YYYY')
     AND cdcooper = 7;

  IF SQL%ROWCOUNT = 2 THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0143679');
    ROLLBACK;
END;