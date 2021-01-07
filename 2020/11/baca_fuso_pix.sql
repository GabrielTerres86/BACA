BEGIN
  INSERT INTO craptab
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
    ,'DIF_FUSO_CABINEPIX'
    ,0
    ,'3'
    ,3);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    Sistema.excecaoInterna;
END;
