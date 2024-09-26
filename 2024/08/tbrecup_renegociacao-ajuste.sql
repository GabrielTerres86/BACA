BEGIN
  UPDATE recuperacao.tbrecup_renegociacao a
     SET a.nrcontrato_renegociado = 8150407
   WHERE a.idrenegociacao = 155;
  COMMIT;
END;
