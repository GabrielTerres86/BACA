BEGIN
	INSERT INTO tbpix_dominio_campo VALUES ('PIX_ORIGEM_SINCRONISMO', 'C', 'Criação da chave');
	INSERT INTO tbpix_dominio_campo VALUES ('PIX_ORIGEM_SINCRONISMO', 'E', 'Exclusão da chave');
	INSERT INTO tbpix_dominio_campo VALUES ('PIX_ORIGEM_SINCRONISMO', 'P', 'Criação da portabilidade');
	INSERT INTO tbpix_dominio_campo VALUES ('PIX_ORIGEM_SINCRONISMO', 'R', 'Criação da reivindicação');
	INSERT INTO tbpix_dominio_campo VALUES ('PIX_ORIGEM_SINCRONISMO', 'A', 'Aprovação');
	INSERT INTO tbpix_dominio_campo VALUES ('PIX_ORIGEM_SINCRONISMO', 'D', 'Duplicidade de chave');
	COMMIT;
END;