 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela APRDES - Script de carga de permissões
    Projeto     : 403 - Desconto de Títulos - Release 4
    Autor       : Luis Fernando (GFT)
    Data        : 07/01/2019
    Objetivo    : Cadastra as permissões dos usuários da mesa de checagem
  ---------------------------------------------------------------------------------------------------------------------*/ 


DECLARE 
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(5); -- EX: Cooperativas(1,3,7,11);
  
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
           AND trim(upper(ope.cdoperad)) IN ('F0050191',
                                              'F0050045',
                                              'F0050040',
                                              'F0050109'
                                            );
    
  END LOOP;
  
   
 UPDATE crapbdt bdt
    SET bdt.vltxmult = 0
  WHERE bdt.cdcooper = 12
    AND bdt.nrborder = 14764; 
  
commit;
end;