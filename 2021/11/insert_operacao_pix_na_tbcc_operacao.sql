BEGIN
  INSERT INTO tbcc_operacao(cdoperacao, dsoperacao)
	VALUES (24, 'PIX - CREDITO, DEBITO E DEVOLUÇÃO ESTORNO');

	INSERT INTO tbcc_operacao(cdoperacao, dsoperacao)
	VALUES (25, 'PIX - ESTORNO');
	
	COMMIT;

	EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK;
END;