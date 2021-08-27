BEGIN
  UPDATE tbapi_controle_senha
     SET flbloqueado = 0
   WHERE cdcooper = 11
     AND nrdconta = 191930;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
