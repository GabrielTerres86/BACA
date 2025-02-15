 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela APRDES - Script de carga de permiss�es
    Projeto     : 403 - Desconto de T�tulos - Release 4
    Autor       : Luis Fernando (GFT)
    Data        : 11/01/2019
    Objetivo    : Cadastra as permiss�es dos usu�rios da mesa de checagem
  ---------------------------------------------------------------------------------------------------------------------*/ 

DECLARE 
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(14); -- EX: Cooperativas(1,3,7,11);
  
  pr_cdcooper INTEGER;
BEGIN

  FOR i IN coop.FIRST .. coop.LAST
  LOOP
    pr_cdcooper := coop(i);
    
    -- Insere as permiss�es de acesso para a tela
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
           AND trim(upper(ope.cdoperad)) IN ('F0140108',
                                              'F0140132',
                                              'F0140113'
                                            );
    
  END LOOP;
commit;
end;
