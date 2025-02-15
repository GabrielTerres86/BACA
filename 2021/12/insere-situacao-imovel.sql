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

INSERT INTO TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES ('INSITIMOVEL', '7', 'Em processamento');

INSERT INTO TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES ('INSITIMOVEL', '8', 'Efetivado sem registro');

INSERT INTO TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
VALUES ('INSITIMOVEL', '9', 'Todas');
 
commit;

exception
	when others then
		ROLLBACK;
end;
