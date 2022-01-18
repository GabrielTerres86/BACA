DECLARE
BEGIN
insert into cecred.tbgen_dominio_campo (nmdominio, cddominio, dscodigo) values ('CALRIS_STATUS_TANQUE', '13', 'Aguardando envio de cadidato');
insert into cecred.tbgen_dominio_campo (nmdominio, cddominio, dscodigo) values ('CALRIS_STATUS_TANQUE', '14', 'Envio de cadidato a Gupy com erro');
insert into cecred.tbgen_dominio_campo (nmdominio, cddominio, dscodigo) values ('CALRISPES_SITUACAO', '8', 'Aguardando envio de cadidato');
COMMIT;
END;
/
