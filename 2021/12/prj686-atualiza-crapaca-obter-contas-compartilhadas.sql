BEGIN
	UPDATE CECRED.CRAPACA SET NMPROCED = 'INTERNETBANKING.obterCtasCompartMensageria' WHERE nmdeacao = 'OBTER_CONTAS_COMPARTILHADAS';
	
	COMMIT;
END;