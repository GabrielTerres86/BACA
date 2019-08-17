 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Ajuste de permissões da tela TITCTO
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Luis Fernando (GFT)
    Data        : 07/01/2019
    Objetivo    : Realiza o ajuste das permissões de acesso da tela TITCTO
  ---------------------------------------------------------------------------------------------------------------------*/ 


DECLARE 
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(1,14); -- EX: Cooperativas(1,3,7,11);
  
  pr_cdcooper INTEGER;

BEGIN
  

  FOR i IN coop.FIRST .. coop.LAST
  LOOP
    pr_cdcooper := coop(i);
    
    -- Copia as permissões existentes da TITCTO
    INSERT INTO crapace
        (nmdatela,
         cddopcao,
         cdoperad,   
         nmrotina,   
         cdcooper,   
         nrmodulo,   
         idevento,   
         idambace)
        SELECT acn.nmdatela, 
               acn.cddopcao, 
               ope.cdoperad,
               ' ',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               2
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.flgativo = 1
           AND cop.cdcooper = (pr_cdcooper)
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           --AND acn.cddopcao = 'L'
           AND UPPER(acn.nmrotina) = ' '
           AND UPPER(acn.nmdatela) = 'TITCTO'
           AND acn.idambace = 1
           AND NOT EXISTS (SELECT 1
                            FROM crapcop cop2,
                                 crapope ope2,
                                 crapace acn2
                           WHERE cop2.flgativo = 1
                             AND cop2.cdcooper = cop.cdcooper
                             AND ope2.cdsitope = 1 
                             AND cop2.cdcooper = ope2.cdcooper
                             AND acn2.cdcooper = ope2.cdcooper
                             AND trim(upper(acn2.cdoperad)) = trim(upper(ope2.cdoperad))
                             --AND acn.cddopcao = 'L'
                             AND trim(upper(acn2.cdoperad)) = trim(upper(acn.cdoperad))
                             AND UPPER(acn2.nmrotina) = ' '
                             AND UPPER(acn2.nmdatela) = 'TITCTO'
                             AND acn2.idambace = 2);
    /*
    -- Insere a permissão da nova opção
    INSERT INTO crapace
        (nmdatela,
         cddopcao,
         cdoperad,   
         nmrotina,   
         cdcooper,   
         nrmodulo,   
         idevento,   
         idambace)
        SELECT acn.nmdatela, 
               'B', 
               ope.cdoperad,
               ' ',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               2
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.flgativo = 1
           AND cop.cdcooper = (pr_cdcooper)
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           AND acn.cddopcao = 'L'
           AND UPPER(acn.nmrotina) = ' '
           AND UPPER(acn.nmdatela) = 'TITCTO'
           AND acn.idambace = 1
           AND NOT EXISTS (SELECT 1
                            FROM crapcop cop2,
                                 crapope ope2,
                                 crapace acn2
                           WHERE cop2.flgativo = 1
                             AND cop2.cdcooper = cop.cdcooper
                             AND ope2.cdsitope = 1 
                             AND cop2.cdcooper = ope2.cdcooper
                             AND acn2.cdcooper = ope2.cdcooper
                             AND trim(upper(acn2.cdoperad)) = trim(upper(ope2.cdoperad))
                             AND acn2.cddopcao = 'B'
                             AND trim(upper(acn2.cdoperad)) = trim(upper(acn.cdoperad))
                             AND UPPER(acn2.nmrotina) = ' '
                             AND UPPER(acn2.nmdatela) = 'TITCTO'
                             AND acn2.idambace = 2);
    */
  END LOOP;
    
  COMMIT;
END;