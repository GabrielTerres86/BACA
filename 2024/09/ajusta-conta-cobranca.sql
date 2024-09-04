BEGIN
  INSERT INTO cobranca.tbcobran_ailosmais_conta_corrente
  (nrconta_corrente
  ,cdcooperativa
  ,dsdominio)
VALUES
  (18712665
  ,1
  ,'ACORDO - COM DESCONTO');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ' || SQLERRM);
    ROLLBACK;
END;
