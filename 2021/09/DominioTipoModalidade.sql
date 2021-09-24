BEGIN
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','1','CONCESSAO');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','2','PORTABILIDADE');
insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','3','CONSTRUCAO');     
COMMIT;
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
END;
