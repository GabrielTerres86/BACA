declare

begin

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_TPCALCULADORA', '1', 'Cooperado PF');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_TPCALCULADORA', '2', 'Cooperado PJ');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_TPCALCULADORA', '3', 'Fornecedores');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_TPCALCULADORA', '4', 'Colaboradores');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_TPCALCULADORA', '5', 'Terceiros');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_STATUS_TANQUE', '10', 'Aguardando lista interna');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_STATUS_TANQUE', '11', 'Lista interna com erro');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_STATUS_TANQUE', '12', 'Dados desatualizados');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRISPES_SITUACAO', '7', 'Aguardando lista interna');

commit;

exception
	when others then
		ROLLBACK;
end;
/
