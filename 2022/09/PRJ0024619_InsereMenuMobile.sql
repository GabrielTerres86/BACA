BEGIN
  INSERT INTO cecred.menumobile
    (menumobileid
    ,menupaiid
    ,nome
    ,sequencia
    ,habilitado
    ,autorizacao
    ,versaominimaapp
    ,versaomaximaapp)
  VALUES
    (1045
    ,1018
    ,'Simular Renegociação de Contratos'
    ,1
    ,1
    ,1
    ,'2.16.0'
    ,NULL);

  INSERT INTO cecred.menumobile
    (menumobileid
    ,menupaiid
    ,nome
    ,sequencia
    ,habilitado
    ,autorizacao
    ,versaominimaapp
    ,versaomaximaapp)
  VALUES
    (1046
    ,1018
    ,'Contratos Renegociados'
    ,2
    ,1
    ,1
    ,'2.16.0'
    ,NULL);

  INSERT INTO cecred.menumobile
    (menumobileid
    ,menupaiid
    ,nome
    ,sequencia
    ,habilitado
    ,autorizacao
    ,versaominimaapp
    ,versaomaximaapp)
  VALUES
    (1047
    ,1018
    ,'Simular Acordo de Contratos'
    ,3
    ,1
    ,1
    ,'2.16.0'
    ,NULL);

  INSERT INTO cecred.menumobile
    (menumobileid
    ,menupaiid
    ,nome
    ,sequencia
    ,habilitado
    ,autorizacao
    ,versaominimaapp
    ,versaomaximaapp)
  VALUES
    (1048
    ,1018
    ,'Consultar Acordos'
    ,4
    ,1
    ,1
    ,'2.16.0'
    ,NULL);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
