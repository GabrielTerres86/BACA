BEGIN
  -- Excluir operacao duplicada
  DELETE FROM tbrecarga_operacao o WHERE o.idoperacao = 1546327;
  COMMIT;
END;
