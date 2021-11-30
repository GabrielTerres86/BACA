BEGIN
  DELETE FROM tbcc_operacoes_diarias
  WHERE cdcooper = 12
    AND dtoperacao = '30/11/2021'
    AND cdoperacao in(18, 19, 20, 24, 25)

  COMMIT;
END;
