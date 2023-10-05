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
    ,10
    ,'F0034369'
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
    ,11
    ,'F0034418'
    ,3);    
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'RITM0333578');
    ROLLBACK;
END;
