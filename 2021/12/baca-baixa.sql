DECLARE

BEGIN

  INSERT INTO TBGEN_DOMINIO_CAMPO
    (NMDOMINIO, CDDOMINIO, DSCODIGO)
  VALUES
    ('INSITIMOVEL', '9', 'Baixado Manual');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;