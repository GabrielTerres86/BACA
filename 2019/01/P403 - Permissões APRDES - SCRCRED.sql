 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela APRDES - Script de carga de permissões
    Projeto     : 403 - Desconto de Títulos - Release 4
    Autor       : Luis Fernando (GFT)
    Data        : 07/01/2019
    Objetivo    : Cadastra as permissões dos usuários da mesa de checagem
  ---------------------------------------------------------------------------------------------------------------------*/ 


DECLARE 
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(13); -- EX: Cooperativas(1,3,7,11);
  
  pr_cdcooper INTEGER;
begin

  FOR i IN coop.FIRST .. coop.LAST
  LOOP
    pr_cdcooper := coop(i);
    
    
    -- Insere as permissões de acesso para a tela
    INSERT INTO crapace
        (nmdatela,
         cddopcao,
         cdoperad,   
         nmrotina,   
         cdcooper,   
         nrmodulo,   
         idevento,   
         idambace)
        SELECT 'APRDES', 
               '@',
               ope.cdoperad,
               ' ',
               cop.cdcooper,
               1,
               0,
               2
          FROM crapcop cop,
               crapope ope
         WHERE cop.cdcooper IN (pr_cdcooper) 
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND trim(upper(ope.cdoperad)) IN ('F0130101',
                                              'F0130043',
                                              'F0130189',
                                              'F0130197'
                                            );
    
  END LOOP;
commit;
end;