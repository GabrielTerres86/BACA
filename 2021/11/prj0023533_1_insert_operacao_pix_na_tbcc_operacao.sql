BEGIN
  INSERT INTO cecred.tbcc_operacao(cdoperacao, dsoperacao)
	VALUES (24, 'PIX - CREDITO, DEBITO E DEVOLUCAO ESTORNO');

	INSERT INTO cecred.tbcc_operacao(cdoperacao, dsoperacao)
	VALUES (25, 'PIX - ESTORNO');
	
	COMMIT;

	EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK; 
END;