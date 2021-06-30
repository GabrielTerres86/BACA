BEGIN
  INSERT INTO cecred.tbcadast_dominio_campo (
    nmdominio
    , cddominio
    , dscodigo
  ) VALUES (
    'TPCORRELACIONADO'
    , '1'
    , 'Conjuge'
  );
  --
  INSERT INTO cecred.tbcadast_dominio_campo (
    nmdominio
    , cddominio
    , dscodigo
  ) VALUES (
    'TPCORRELACIONADO'
    , '2'
    , 'Representante Legal'
  );
  --
  INSERT INTO cecred.tbcadast_dominio_campo (
    nmdominio
    , cddominio
    , dscodigo
  ) VALUES (
    'TPCORRELACIONADO'
    , '3'
    , 'Procurador'
  );
  --
  COMMIT;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar o script: ' || SQLERRM);
    --
END;
