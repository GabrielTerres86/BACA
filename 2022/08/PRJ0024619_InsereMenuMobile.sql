BEGIN
  DELETE 
    FROM cecred.menumobile
   WHERE menumobileid IN (1047, 1048);

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
    ,'Simular Acordo'
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
    ,'Acompanhar Acordos'
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
