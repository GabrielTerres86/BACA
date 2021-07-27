BEGIN
	UPDATE tbcc_lancamentos_pendentes set idsituacao = 'M', dscritica = 'INC0098669' WHERE nrdcmto = 20021158;
  COMMIT;
END;