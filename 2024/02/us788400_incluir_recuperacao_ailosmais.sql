BEGIN

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (18266126
    ,1
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (1250159
    ,2
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (384631
    ,6
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (306355
    ,5
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (484504
    ,7
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (65900
    ,8
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (591548
    ,9
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (259144
    ,10
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (1036939
    ,11
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (217557
    ,12
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (781010
    ,13
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (488569
    ,14
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
    (nrconta_corrente
    ,cdcooperativa
    ,dsdominio)
  VALUES
    (1117190
    ,16
    ,'RECUPERAÇÃO DE CRÉDITO');
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
