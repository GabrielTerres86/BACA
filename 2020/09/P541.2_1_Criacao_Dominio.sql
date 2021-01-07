BEGIN
	INSERT INTO tbgen_dominio_campo (nmdominio, cddominio, dscodigo) VALUES ('TPPRODUTO_APROVACAO', 1, 'Empréstimo/Financiamento');
	INSERT INTO tbgen_dominio_campo (nmdominio, cddominio, dscodigo) VALUES ('TPPRODUTO_APROVACAO', 2, 'Limite de Cartão de Crédito');
	INSERT INTO tbgen_dominio_campo (nmdominio, cddominio, dscodigo) VALUES ('TPPRODUTO_APROVACAO', 3, 'Limite de Desconto de Título');
	INSERT INTO tbgen_dominio_campo (nmdominio, cddominio, dscodigo) VALUES ('TPPRODUTO_APROVACAO', 4, 'Borderô de Desconto de Título');
	COMMIT;
END;