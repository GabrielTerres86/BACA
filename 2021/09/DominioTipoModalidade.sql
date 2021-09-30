BEGIN
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','1','Construcao Isolada');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','2','Condominio');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','3','Empresario');     
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','4','Cooperativa');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','5','Revenda');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','6','Adquirido');     
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','7','Aquisicao Isolada');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','8','Adquirido BNH RD 61/71');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','9','Construcao Conjunto Habitacional');   
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','10','Reforma ou Ampliacao');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','11','Material de Construcao');       
COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
END;