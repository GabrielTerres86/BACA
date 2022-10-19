BEGIN
	INSERT INTO crapprm
	 (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
	VALUES
	 ('CRED', 0, 'APROV_BOLETO_ANTIFRAUDE', 'Chave Liga/Desliga a alteração referente ao novo processo de aprovação/reprovação dos boletos na análise anti fraude', '0');
	COMMIT;
END;
/