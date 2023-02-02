BEGIN
  INSERT INTO crapcri
    (CDCRITIC
    ,DSCRITIC
    ,TPCRITIC
    ,FLGCHAMA)
  VALUES
    (1506
    ,'1506 - Codigo da Carteira invalido'
    ,4
    ,0);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441');
    ROLLBACK;
END;
  
