BEGIN
  -- Insere um registro.
  INSERT ALL 
    INTO cecred.TBCC_DOMINIO_CAMPO (
      nmdominio
      , cddominio
      , dscodigo
    )
    values (
      'TBCC_ASSOCIADOS.IDATIVACAO'
      , '-1'
      , ''
    )
    --
    INTO cecred.TBCC_DOMINIO_CAMPO (
      nmdominio
      , cddominio
      , dscodigo
    )
    values (
      'TBCC_ASSOCIADOS.IDATIVACAO'
      , '0'
      , 'Ativo'
    )
    --
    INTO cecred.TBCC_DOMINIO_CAMPO (
      nmdominio
      , cddominio
      , dscodigo
    )
    VALUES (
      'TBCC_ASSOCIADOS.IDATIVACAO'
      , '1'
      , 'Pr�-Inativo'
    )
    --
    INTO cecred.TBCC_DOMINIO_CAMPO (
      nmdominio
      , cddominio
      , dscodigo
    )
    VALUES (
      'TBCC_ASSOCIADOS.IDATIVACAO'
      , '2'
      , 'N�o Ativado'
    )
    --
    INTO cecred.TBCC_DOMINIO_CAMPO (
      nmdominio
      , cddominio
      , dscodigo
    )
    VALUES (
      'TBCC_ASSOCIADOS.IDATIVACAO'
      , '3'
      , 'Inativo'
    )
    select 1 from dual;
  --
  COMMIT;
  --
  DBMS_OUTPUT.PUT_LINE('Sucesso na atualiza��o.');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;
