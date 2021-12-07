declare

begin

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INSITIMOVEL', '7', 'Em processamento');


commit;

exception
  when others then
    ROLLBACK;
end;
