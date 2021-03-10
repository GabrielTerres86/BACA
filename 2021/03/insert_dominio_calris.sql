declare

begin

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('CALRIS_SITUACAO', '4', 'Reprovada');
commit;

exception
	when others then
		null;
end;
/