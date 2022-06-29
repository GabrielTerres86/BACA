BEGIN
  INSERT INTO crapcri
    (CDCRITIC
    ,DSCRITIC
    ,TPCRITIC
    ,FLGCHAMA)
  VALUES
    (1514
    ,'1514 - Repasse em Duplicidade pela IF Recebedora'
    ,4
    ,0);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441');
    ROLLBACK;
END;
  
