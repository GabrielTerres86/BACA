declare

begin

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_TPCALCULADORA', '1', 'Cooperados');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_TPCALCULADORA', '2', 'Fornecedores');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_TPCALCULADORA', '3', 'Colaboradores');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_TPCALCULADORA', '4', 'Terceiros');

commit;

exception
	when others then
		null;
end;
/
