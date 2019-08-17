BEGIN
	-- Data de corte para solicitação e exibição da assinatura eletronica para cartão de crédito P432
	INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
				 VALUES ('CRED', 0, 'ASS_ELET_CARTAO_TERMO', 'Data de corte para solicitação e exibição da assinatura eletronica para cartão de crédito', '22/01/2018');

	COMMIT;
END;