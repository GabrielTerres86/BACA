BEGIN
  INSERT INTO tbgen_batch_param
    (IDPARAMETRO
    ,QTPARALELO
    ,QTREG_TRANSACAO
    ,CDCOOPER
    ,CDPROGRAMA)
  VALUES
    ((SELECT MAX(idparametro) + 1
       FROM tbgen_batch_param)
    ,20
    ,0
    ,1
    ,'CRPS172');
	
	INSERT INTO tbgen_batch_param
    (IDPARAMETRO
    ,QTPARALELO
    ,QTREG_TRANSACAO
    ,CDCOOPER
    ,CDPROGRAMA)
  VALUES
    ((SELECT MAX(idparametro) + 1
       FROM tbgen_batch_param)
    ,20
    ,0
    ,1
    ,'CRPS654');

  COMMIT;
END;
