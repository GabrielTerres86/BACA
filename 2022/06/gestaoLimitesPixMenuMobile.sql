DECLARE
BEGIN
	insert into menumobile (MENUMOBILEID, MENUPAIID, NOME, SEQUENCIA, HABILITADO, AUTORIZACAO, VERSAOMINIMAAPP, VERSAOMAXIMAAPP)
	values (1040, 1021, 'Gest�o de Hor�rios', 1, 1, 1, '2.37.0', null);
	
	insert into menumobile (MENUMOBILEID, MENUPAIID, NOME, SEQUENCIA, HABILITADO, AUTORIZACAO, VERSAOMINIMAAPP, VERSAOMAXIMAAPP)
	values (1041, 1021, 'Cadastro de Conta', 1, 1, 1, '2.99.0', null);
	
	insert into menumobile (MENUMOBILEID, MENUPAIID, NOME, SEQUENCIA, HABILITADO, AUTORIZACAO, VERSAOMINIMAAPP, VERSAOMAXIMAAPP)
	values (1042, 1021, 'D�vidas', 1, 1, 1, '2.99.0', null);
	
	commit;
END;