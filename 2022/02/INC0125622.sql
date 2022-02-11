BEGIN
  --
  UPDATE tbcobran_devolucao dev
     SET dtmvtolt = TO_DATE('10/02/2022', 'DD/MM/YYYY')
   WHERE dev.cdcooper = 1
     AND dev.dtmvtolt = TO_DATE('08/02/2022', 'DD/MM/YYYY');
  --
  IF SQL%ROWCOUNT = 12 THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 1, pr_compleme => 'INC0125622');
    ROLLBACK;
END;
