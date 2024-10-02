BEGIN
  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (1
    ,19419988
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (2
    ,1260979
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (6
    ,309656
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (5
    ,387282
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (7
    ,492752
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (8
    ,66079
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (9
    ,605166
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (10
    ,264598
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (11
    ,1051571
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (12
    ,219568
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (13
    ,792152
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (14
    ,501956
    ,'RECUPERAÇÃO DE CRÉDITO');

  INSERT INTO COBRANCA.tbcobran_ailosmais_conta_corrente
    (cdcooperativa
    ,nrconta_corrente
    ,dsdominio)
  VALUES
    (16
    ,1134523
    ,'RECUPERAÇÃO DE CRÉDITO');

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'us975140-contas-aimaro-ailosmais.sql');
    RAISE;
END;
