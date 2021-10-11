BEGIN
    insert into tbgen_dominio_campo(nmdominio,cddominio,dscodigo) values ('TIPOMODALIDADEIMOB','0','Desconhecido');
    
    COMMIT;

EXCEPTION
 WHEN OTHERS THEN
  RAISE_application_error(-20500,SQLERRM);
  ROLLBACK;
END;