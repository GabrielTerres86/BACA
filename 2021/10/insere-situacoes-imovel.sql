declare

begin

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INSITIMOVEL', '1', 'Nao enviado');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INSITIMOVEL', '2', 'Registrado via arquivo');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INSITIMOVEL', '3', 'Registrado manual');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INSITIMOVEL', '4', 'Processado com Critica');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INSITIMOVEL', '5', 'Baixado via arquivo');

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INSITIMOVEL', '6', 'Baixado manual');

 
commit;

exception
	when others then
		ROLLBACK;
end;
