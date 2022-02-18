BEGIN
  update INTERNETBANKING.tbib_mult_contas set dhatualizacao = null;
  COMMIT;
END;