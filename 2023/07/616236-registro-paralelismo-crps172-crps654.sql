BEGIN

  INSERT INTO CECRED.tbgen_batch_param
    (IDPARAMETRO
    ,QTPARALELO
    ,QTREG_TRANSACAO
    ,CDCOOPER
    ,CDPROGRAMA)
  VALUES
    ((SELECT MAX(idparametro) + 1
       FROM CECRED.tbgen_batch_param)
    ,20
    ,0
    ,1
    ,'CRPS172');
	
	INSERT INTO CECRED.tbgen_batch_param
    (IDPARAMETRO
    ,QTPARALELO
    ,QTREG_TRANSACAO
    ,CDCOOPER
    ,CDPROGRAMA)
  VALUES
    ((SELECT MAX(idparametro) + 1
       FROM CECRED.tbgen_batch_param)
    ,20
    ,0
    ,1
    ,'CRPS654');

  COMMIT;
END;
