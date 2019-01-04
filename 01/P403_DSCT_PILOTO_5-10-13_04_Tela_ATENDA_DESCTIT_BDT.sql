 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela ATENDA->DESCONTOS->TITULOS->BORDEROS - Script de carga
    Projeto     : 403 - Desconto de T�tulos - Release 4
    Autor       : Luis Fernando (GFT)
    Data        : Janeiro/2019
    Objetivo    : Realiza o cadastro das novas funcionalidades da tela ATENDA->DESCONTOS->T�TULOS->BORDER�S
  ---------------------------------------------------------------------------------------------------------------------*/ 

DECLARE 
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(5,10,13); -- EX: Cooperativas(1,3,7,11);
  
  pr_cdcooper INTEGER;
begin

-- remove qualquer "lixo" de BD que possa ter  
/*
DELETE FROM crapace acn 
      WHERE acn.cddopcao IN ('I','R','A')
        AND acn.nmrotina = 'DSC TITS - BORDERO'
        AND acn.nmdatela = 'ATENDA'
        AND acn.idambace = 2
        and cdcooper = 16;
*/
 FOR i IN coop.FIRST .. coop.LAST
  LOOP
    pr_cdcooper := coop(i);
    -- Atualiza as permiss�es das telas de border�
    UPDATE craptel 
       SET cdopptel = cdopptel||',P,I,R,A,E,X',
           lsopptel = lsopptel||',PAGAR,INCLUIR,REJEITAR,ALTERAR,EXCLUIR,EXTRATO',
           idambtel = 2 -- Ayllos Web
     WHERE nmrotina = 'DSC TITS - BORDERO'
       AND nmdatela = 'ATENDA'
       AND cdcooper IN (pr_cdcooper); /*14);*/ 

    -- Fornece as permiss�es de acesso dos bot�es novos para os usu�rios que j� possuem permiss�o na tela de border�s
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
               'P', -- Pagar
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               acn.idambace
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper IN (pr_cdcooper) /*14);*/ 
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           AND acn.cddopcao = 'P' -- Bot�o Pagar Empr�stimos
           AND acn.nmdatela = 'ATENDA'
           AND acn.nmrotina = 'PRESTACOES'
           AND acn.idambace = 2
         UNION    
         SELECT 'ATENDA', 
               'P', -- Pagar
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               acn.idambace
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper IN (pr_cdcooper) /*14);*/ 
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           AND trim(upper(ope.cdoperad)) IN ('F0030584', 'F0030978') -- permiss�es para a �rea de neg�cio 
           AND acn.cddopcao = '@' 
           AND acn.nmdatela = 'ATENDA'
           AND acn.nmrotina = 'DSC TITS - BORDERO'
           AND acn.idambace = 2;

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
               'I', -- Incluir
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               2
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper IN (pr_cdcooper) /*14);*/ 
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           AND acn.cddopcao = 'I'
           AND acn.nmdatela = 'LANBDT'
           AND acn.idambace = 1
         UNION    
        SELECT 'ATENDA', 
               'I', -- Incluir
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               acn.idambace
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper IN (pr_cdcooper) /*14);*/ 
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           AND trim(upper(ope.cdoperad)) IN ('F0030584', 'F0030978') -- permiss�es para a �rea de neg�cio 
           AND acn.cddopcao = '@'
           AND acn.nmdatela = 'ATENDA'
           AND acn.nmrotina = 'DSC TITS - BORDERO'
           AND acn.idambace = 2;

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
               'R', -- Rejeitar
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               2
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper IN (pr_cdcooper) /*14);*/ 
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           AND acn.cddopcao = 'I'
           AND acn.nmdatela = 'LANBDT'
           AND acn.idambace = 1
         UNION    
        SELECT 'ATENDA', 
               'R', -- Rejeitar
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               acn.idambace
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper IN (pr_cdcooper) /*14);*/ 
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           AND trim(upper(ope.cdoperad)) IN ('F0030584', 'F0030978') -- permiss�es para a �rea de neg�cio 
           AND acn.cddopcao = '@'
           AND acn.nmdatela = 'ATENDA'
           AND acn.nmrotina = 'DSC TITS - BORDERO'
           AND acn.idambace = 2;

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
               'A', -- Alterar
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               2
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper IN (pr_cdcooper) /*14);*/ 
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           AND acn.cddopcao = 'A'
           AND acn.nmdatela = 'LANBDT'
           AND acn.idambace = 1
         UNION    
        SELECT 'ATENDA', 
               'A', -- Rejeitar
               ope.cdoperad,
               'DSC TITS - BORDERO',
               acn.cdcooper,
               acn.nrmodulo,
               acn.idevento,
               acn.idambace
          FROM crapcop cop,
               crapope ope,
               crapace acn
         WHERE cop.cdcooper IN (pr_cdcooper) /*14);*/ 
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND acn.cdcooper = ope.cdcooper
           AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
           AND trim(upper(ope.cdoperad)) IN ('F0030584', 'F0030978') -- permiss�es para a �rea de neg�cio 
           AND acn.cddopcao = '@'
           AND acn.nmdatela = 'ATENDA'
           AND acn.nmrotina = 'DSC TITS - BORDERO'
           AND acn.idambace = 2;
    
  END LOOP;
commit;
end;