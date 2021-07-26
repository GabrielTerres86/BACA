BEGIN
	UPDATE tbcc_lancamentos_pendentes set idsituacao = 'M', dscritica = 'RDM0040501' WHERE nrdcmto = 20021158;
  COMMIT;
END;