BEGIN
  DELETE FROM cecred.tbcc_operacoes_diarias
  WHERE cdcooper = 12
    AND dtoperacao = to_date('30/11/2021','DD-MM-YYYY') 
    AND cdoperacao in(18, 19, 20, 24, 25);

  COMMIT;
END;
