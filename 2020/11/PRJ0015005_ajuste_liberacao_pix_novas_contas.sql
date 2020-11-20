BEGIN
  UPDATE tbpix_crapass SET flliberacao_restrita = 1 WHERE flliberacao_restrita = 0;
  COMMIT;
END;