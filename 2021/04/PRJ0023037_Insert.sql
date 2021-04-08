begin

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '10', 'Residêncial', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '13', 'Correspondência', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '14', 'Complementar', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '9', 'Comercial', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '90', 'PA', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '91', 'Outro PA', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPFUNCIONALIDADEENTREGA', '2', 'Envio de cartão de crédito VISA - Unicred para o endereço do cooperado', 1);

	Commit;
	
end;
