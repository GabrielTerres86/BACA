begin

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '10', 'Resid�ncial', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '13', 'Correspond�ncia', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '14', 'Complementar', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '9', 'Comercial', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '90', 'PA', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPENDERECOENTREGAUNICRED', '91', 'Outro PA', 1);

	insert into tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	values ('TPFUNCIONALIDADEENTREGA', '2', 'Envio de cart�o de cr�dito VISA - Unicred para o endere�o do cooperado', 1);

	Commit;
	
end;
