BEGIN

  UPDATE cecred.crapdat dat
     SET dat.dtmvtocd = to_date('25/01/2024', 'dd/mm/yyyy')
   WHERE dat.cdcooper IN (8, 9);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'altera ocd');
END;
