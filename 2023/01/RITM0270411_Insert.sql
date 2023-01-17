BEGIN
  INSERT INTO CECRED.craptab
    (NMSISTEM
    ,TPTABELA
    ,CDEMPRES
    ,CDACESSO
    ,TPREGIST
    ,DSTEXTAB
    ,CDCOOPER)
  VALUES
    ('CRED'
    ,'GENERI'
    ,0
    ,'USRCOBRBAIXA'
    ,7
    ,'f0033708'
    ,3);

  INSERT INTO CECRED.craptab
    (NMSISTEM
    ,TPTABELA
    ,CDEMPRES
    ,CDACESSO
    ,TPREGIST
    ,DSTEXTAB
    ,CDCOOPER)
  VALUES
    ('CRED'
    ,'GENERI'
    ,0
    ,'USRCOBRBAIXA'
    ,8
    ,'f0032937'
    ,3);

  INSERT INTO CECRED.craptab
    (NMSISTEM
    ,TPTABELA
    ,CDEMPRES
    ,CDACESSO
    ,TPREGIST
    ,DSTEXTAB
    ,CDCOOPER)
  VALUES
    ('CRED'
    ,'GENERI'
    ,0
    ,'USRCOBRBAIXA'
    ,9
    ,'f0033890'
    ,3);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'RITM0270411');
    ROLLBACK;
END;
