-- Realizar cadastro da tela/permissoes RECCRD 
DECLARE

BEGIN
  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop cop
                      WHERE cop.flgativo = 1) LOOP
  
    -- Cadastro da tela RECCRD
    INSERT INTO craptel
      (NMDATELA
      ,NRMODULO
      ,CDOPPTEL
      ,TLDATELA
      ,TLRESTEL
      ,FLGTELDF
      ,FLGTELBL
      ,NMROTINA
      ,LSOPPTEL
      ,INACESSO
      ,CDCOOPER
      ,IDSISTEM
      ,IDEVENTO
      ,NRORDROT
      ,NRDNIVEL
      ,NMROTPAI
      ,IDAMBTEL)
    VALUES
      ('RECCRD'
      ,3
      ,'@,C,A'
      ,'Reciprocidade de Credito'
      ,'Reciprocidade de Credito'
      ,0
      ,1
      ,' '
      ,'ACESSO,CONSULTA,ALTERACAO'
      ,1
      ,rw_crapcop.cdcooper
      ,1
      ,0
      ,1
      ,1
      ,' '
      ,2);
  
    -- Insere o registro de cadastro do programa
    INSERT INTO crapprg
      (nmsistem
      ,cdprogra
      ,dsprogra##1
      ,dsprogra##2
      ,dsprogra##3
      ,dsprogra##4
      ,nrordprg
      ,inctrprg
      ,cdrelato##1
      ,cdrelato##2
      ,cdrelato##3
      ,cdrelato##4
      ,cdrelato##5
      ,inlibprg
      ,cdcooper)
      SELECT 'CRED'
            ,'RECCRD'
            ,'Reciprocidade de Credito'
            ,' '
            ,' '
            ,' '
            ,(SELECT MAX(crapprg.nrordprg) + 1
               FROM crapprg
              WHERE crapprg.cdcooper = crapcop.cdcooper
                AND crapprg.nrsolici = 50)
            ,1
            ,0
            ,0
            ,0
            ,0
            ,0
            ,1
            ,cdcooper
        FROM crapcop
       WHERE cdcooper = rw_crapcop.cdcooper;
  
    -- Permissões de consulta (C) tela RECCRD
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
      SELECT 'RECCRD'
            ,'C'
            ,ope.cdoperad
            ,' '
            ,ope.cdcooper
            ,1
            ,0
            ,2
        FROM crapace ace
            ,crapope ope
       WHERE UPPER(ace.nmdatela) = 'LCREDI'
         AND UPPER(ace.cddopcao) = 'C'
         AND UPPER(ace.nmrotina) = ' '
         AND ace.cdcooper = rw_crapcop.cdcooper
         AND ace.idambace = 2
         AND ope.cdcooper = ace.cdcooper
         AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
         AND ope.cdsitope = 1;
  
    -- Permissões de alteracao (A) tela RECCRD
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
      SELECT 'RECCRD'
            ,'A'
            ,ope.cdoperad
            ,' '
            ,ope.cdcooper
            ,1
            ,0
            ,2
        FROM crapace ace
            ,crapope ope
       WHERE UPPER(ace.nmdatela) = 'LCREDI'
         AND UPPER(ace.cddopcao) = 'A'
         AND UPPER(ace.nmrotina) = ' '
         AND ace.cdcooper = rw_crapcop.cdcooper
         AND ace.idambace = 2
         AND ope.cdcooper = ace.cdcooper
         AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
         AND ope.cdsitope = 1;
  
  END LOOP;
END;
