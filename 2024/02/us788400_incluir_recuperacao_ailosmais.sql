BEGIN

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (18266126
    ,1
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (1250159
    ,2
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (384631
    ,6
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (306355
    ,5
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (484504
    ,7
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (65900
    ,8
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (591548
    ,9
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (259144
    ,10
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (1036939
    ,11
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (217557
    ,12
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (781010
    ,13
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (488569
    ,14
    ,'RECUPERA��O DE CR�DITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (1117190
    ,16
    ,'RECUPERA��O DE CR�DITO');
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
