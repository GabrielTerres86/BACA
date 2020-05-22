-- Created on 20/05/2020 by F0030401 
DECLARE

 

BEGIN
  -- Test statements here
  FOR rw_crapcop IN (SELECT c.cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP
  
    DELETE crapace a
     WHERE UPPER(a.NMDATELA) = 'ATENDA'
       AND UPPER(a.NMROTINA) = 'LIMITE CRED'
       AND UPPER(a.cddopcao) = 'D'
       AND a.cdcooper = rw_crapcop.cdcooper;     
  
  END LOOP;

  COMMIT;


  FOR rw_crapcop IN (SELECT c.cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP
  
    -- Permissões de consulta  botão 'Detalhes Propostas' (D) para os usuários                  
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace)
      SELECT 'ATENDA',
             'D',
             ope.cdoperad,
             'LIMITE CRED',
             ope.cdcooper,
             1,
             0,
             2
        FROM crapope ope
       WHERE ope.cdsitope = 1
         AND ope.cdcooper = rw_crapcop.cdcooper
         AND EXISTS (SELECT 1
                FROM crapace a
               WHERE UPPER(a.NMDATELA) = 'ATENDA'
                 AND UPPER(a.cddopcao) = 'N'
                 AND UPPER(a.NMROTINA) = 'LIMITE CRED'
                 AND a.cdcooper = ope.cdcooper
                 AND UPPER(a.cdoperad) = UPPER(ope.cdoperad));
    ------Fim Realizar cadastro de permissoes para botão 'Detalhes Propostas' (D) ------
  
  END LOOP;
  
   COMMIT;
  
END;
