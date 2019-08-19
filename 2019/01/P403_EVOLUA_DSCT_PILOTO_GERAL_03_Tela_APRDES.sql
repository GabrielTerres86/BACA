 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela APRDES - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 4
    Autor       : Luis Fernando (GFT)
    Data        : 07/01/2019
    Objetivo    : Realizar o cadastro da nova tela APRDES no Ayllos Web
  ---------------------------------------------------------------------------------------------------------------------*/ 


DECLARE 
  TYPE Cooperativas IS TABLE OF integer;
  coop Cooperativas := Cooperativas(14); -- EX: Cooperativas(1,3,7,11);
  
  pr_cdcooper INTEGER;
begin

-- remove qualquer "lixo" de BD que possa ter  
/*
DELETE FROM craptel WHERE nmdatela = 'APRDES';
DELETE FROM crapace WHERE nmdatela = 'APRDES';
DELETE FROM crapprg WHERE cdprogra = 'APRDES';
*/
  FOR i IN coop.FIRST .. coop.LAST
  LOOP
    pr_cdcooper := coop(i);
    -- Insere a tela
    INSERT INTO craptel 
        (nmdatela,
         nrmodulo,
         cdopptel,
         tldatela,
         tlrestel,
         flgteldf,
         flgtelbl,
         nmrotina,
         lsopptel,
         inacesso,
         cdcooper,
         idsistem,
         idevento,
         nrordrot,
         nrdnivel,
         nmrotpai,
         idambtel)
        SELECT 'APRDES', 
               5, 
               '@', 
               'Mesa de checagem', 
               'Mesa de checagem', 
               0, 
               1, -- bloqueio da tela 
               ' ', 
               'ACESSO', 
               0, 
               cdcooper, -- cooperativa
               1, 
               0, 
               1, 
               1, 
               '', 
               2 
          FROM crapcop          
         WHERE cdcooper IN (pr_cdcooper); /*,14);*/
    /*
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
         WHERE cop.cdcooper IN (pr_cdcooper) /*14); 
           AND ope.cdsitope = 1 
           AND cop.cdcooper = ope.cdcooper
           AND trim(upper(ope.cdoperad)) IN ('F0011875',
                                             'F0010586',
                                             'F0012326',
                                             'F0010546'
                                            );
    */
    -- Insere o registro de cadastro do programa
    INSERT INTO crapprg
        (nmsistem,
         cdprogra,
         dsprogra##1,
         dsprogra##2,
         dsprogra##3,
         dsprogra##4,
         nrsolici,
         nrordprg,
         inctrprg,
         cdrelato##1,
         cdrelato##2,
         cdrelato##3,
         cdrelato##4,
         cdrelato##5,
         inlibprg,
         cdcooper) 
        SELECT 'CRED',
               'APRDES',
               'Mesa de checagem',
               '.',
               '.',
               '.',
               50,
               (select max(crapprg.nrordprg) + 1 from crapprg where crapprg.cdcooper = crapcop.cdcooper and crapprg.nrsolici = 50),
               1,
               0,
               0,
               0,
               0,
               0,
               1,
               cdcooper
          FROM crapcop          
         WHERE cdcooper IN (pr_cdcooper); /*14);*/ 
  END LOOP;
commit;
end;