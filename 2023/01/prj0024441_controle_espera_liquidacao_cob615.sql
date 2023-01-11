BEGIN
  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'CTRL_LQD_COB615'
    ,'Quantidade de tempo em segundos para esperar validação do controle de liquidação do COB615'
    ,'10');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441');
    ROLLBACK;
END;
