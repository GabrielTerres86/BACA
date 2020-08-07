DECLARE

  vr_cdopcao VARCHAR2(2);

  -- Cursor para as cooperativas
  CURSOR cr_crapcop IS
    SELECT * FROM crapcop cop WHERE cop.flgativo = 1;

BEGIN

  /*********************************************** ACESSOS TELA CADDES ***********************************************/

  -- Percorrer as cooperativas do cursor
  FOR rw_crapcop IN cr_crapcop LOOP
  
    -- Deletar todos os acessos da tela DEPOSITO_VAREJISTA
    DELETE crapace t
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'ATENDA'
       AND UPPER(t.nmrotina) = 'DEPOSITO_VAREJISTA';
  
    -- Para cada uma das opções da tela DEPOSITO_VAREJISTA
    FOR vr_index IN 1 .. 5 LOOP
    
      -- selecionar a opção
      CASE vr_index
        WHEN 1 THEN vr_cdopcao := '@'; -- Acesso
        WHEN 2 THEN vr_cdopcao := 'C'; -- Consultar
        WHEN 3 THEN vr_cdopcao := 'I'; -- Incluir
        WHEN 4 THEN vr_cdopcao := 'A'; -- Alterar
        WHEN 5 THEN vr_cdopcao := 'E'; -- Cancelar
      END CASE;
    
      -- Liberar acesso a opção para os usuários que tem acesso a tela ATENDA
      INSERT INTO CRAPACE
        (NMDATELA,
         CDDOPCAO,
         CDOPERAD,
         NMROTINA,
         CDCOOPER,
         NRMODULO,
         IDEVENTO,
         IDAMBACE)
        SELECT t.nmdatela,
               vr_cdopcao,
               o.cdoperad,
               t.nmrotina,
               o.cdcooper,
               t.nrmodulo,
               t.idevento,
               t.idambtel
          FROM craptel t, crapope o
         WHERE o.cdcooper = rw_crapcop.cdcooper
           AND UPPER(t.nmdatela) = 'ATENDA'
           AND UPPER(t.nmrotina) = 'DEPOSITO_VAREJISTA'
           AND o.cdcooper = t.cdcooper
           AND o.cdsitope = 1
           AND EXISTS (SELECT 1
                  FROM crapace ace
                 WHERE o.cdcooper = ace.cdcooper
                   AND upper(ace.nmdatela) = 'ATENDA'
                   AND TRIM(UPPER(ace.nmrotina)) is null 
                   AND upper(o.cdoperad) = upper(ace.cdoperad)
                   AND ace.idambace = 2);
    
      COMMIT;
    
    END LOOP;
  
  END LOOP;

END;
