/* Libera acesso a tela MOVCMP para os operadores do  cdcooper = 3. */
DECLARE

  -- INFORME CDCOOPER CURSOR cr_crapcop -- QUAIS COOPERATIVAS
  -- INFORME cddepart CURSOR cr_crapdpo_consulta QUAIS grupos liberados para consulta
  -- INFORME cddepart CURSOR cr_crapdpo_alterar QUAIS grupos liberados para Alteração e consultar 
  -- SIGLA_TELA := 'PARRAT'; 
  sigla_tela VARCHAR2(100) := 'MOVCMP';
  /****************************************/
  -- busca cooperativas
  CURSOR cr_crapcop IS
    SELECT cdcooper, nmrescop
      FROM crapcop
     WHERE flgativo = 1
       AND cdcooper = 3;
  rw_crapcop cr_crapcop%ROWTYPE;

  --- busca operadores do grupo e coopertiva 
  CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_cddepart IN crapope.cddepart%TYPE) IS
    SELECT cdoperad
      FROM crapope
     WHERE cdcooper = pr_cdcooper
       AND cddepart = pr_cddepart
       AND cdsitope = 1;
  rw_crapope  cr_crapope%ROWTYPE;
  v_contcons  NUMBER := 0;
  v_contalter NUMBER := 0;

BEGIN
  --PARA CADA COOPERATIVA CADASTRADA
  FOR rw_crapcop IN cr_crapcop LOOP
  
    --FAZ O INSERT PARA OPERADORES DO GRUPOS APENAS  CONSULTAR
    FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper, 4) LOOP
      v_contcons := nvl(v_contcons, 0) + 1;
      BEGIN
        INSERT INTO crapace
          (nmdatela
          ,cddopcao
          ,cdoperad
          ,nmrotina
          ,cdcooper
          ,nrmodulo
          ,idevento
          ,idambace)
        VALUES
          (sigla_tela
          ,'C'
          ,rw_crapope.cdoperad
          ,' '
          ,rw_crapcop.cdcooper
          ,1
          ,0
          ,2);
      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL;
      END;
    END LOOP; -- FIM CURSOR OPERADORES
  END LOOP; -- FIM GRUPO PARA CONSULTA 

  COMMIT;

EXCEPTION
  WHEN dup_val_on_index THEN
    NULL;
  WHEN OTHERS THEN
    dbms_output.put_line('Encontrado erro' || SQLCODE);
END;
