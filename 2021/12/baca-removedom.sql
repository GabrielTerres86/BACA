BEGIN
delete TBGEN_DOMINIO_CAMPO a where a.nmdominio  = 'INSITIMOVEL' and   a.cddominio = 9;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
