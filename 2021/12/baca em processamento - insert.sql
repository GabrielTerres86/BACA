declare

begin

insert into TBGEN_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO)
values ('INSITIMOVEL', '7', 'Em processamento');


 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
end;
/
