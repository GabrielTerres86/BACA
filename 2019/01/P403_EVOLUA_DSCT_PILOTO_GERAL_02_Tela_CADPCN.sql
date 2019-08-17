 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela CADPCN - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 4
    Autor       : Luis Fernando (GFT)
    Data        : 07/01/2019
    Objetivo    : Realizar o cadastro da nova tela CADPCN no Ayllos Web
  ---------------------------------------------------------------------------------------------------------------------*/ 


BEGIN

-- remove qualquer "lixo" de BD que possa ter  
/*
DELETE FROM craptel WHERE nmdatela = 'CADPCN';
DELETE FROM crapace WHERE nmdatela = 'CADPCN';
DELETE FROM crapprg WHERE cdprogra = 'CADPCN';
*/

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
    SELECT 'CADPCN', 
           5, 
           'C,A,I,E', 
           'Cadastro de valor maximo por CNAE', 
           'Cadastro de valor maximo por CNAE', 
           0, 
           1, -- bloqueio da tela 
           ' ', 
           'CONSULTA,ALTERAR,INCLUIR,EXCLUIR', 
           0, 
           cdcooper, -- cooperativa
           1, 
           0, 
           1, 
           1, 
           '', 
           2 
      FROM crapcop          
     WHERE cdcooper IN (14); /*,14);*/

-- Permissões de consulta para os usuários pré-definidos pela CECRED                       
INSERT INTO crapace
    (nmdatela,
     cddopcao,
     cdoperad,   
     nmrotina,   
     cdcooper,   
     nrmodulo,   
     idevento,   
     idambace)
    SELECT 'CADPCN', 
           'C',
           ope.cdoperad,
           ' ',
           cop.cdcooper,
           1,
           0,
           2
      FROM crapcop cop,
           crapope ope
     WHERE cop.cdcooper IN (14) /*14);*/ 
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND trim(upper(ope.cdoperad)) IN ('1', -- super usuário
                                         'F0030584',
                                         'F0030521',
                                         'F0030066',
                                         'F0030688',
                                         'F0030835',
                                         'F0030513',
                                         'F0031403',
                                         'F0030978',
                                         'F0020517',
                                         'F0030542',
                                         'F0031401',
                                         'F0031089',
                                         'F0031090',
                                         'F0031810',
                                         'F0031809',
                                         'F0031803');

-- Permissões de consulta para os usuários pré-definidos pela CECRED
INSERT INTO crapace
    (nmdatela,
     cddopcao,
     cdoperad,   
     nmrotina,   
     cdcooper,   
     nrmodulo,   
     idevento,   
     idambace)
    SELECT 'CADPCN', 
           'A',
           ope.cdoperad,
           ' ',
           cop.cdcooper,
           1,
           0,
           2
      FROM crapcop cop,
           crapope ope
     WHERE cop.cdcooper IN (14) /*14);*/ 
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND trim(upper(ope.cdoperad)) IN ('1', -- super usuário
                                         'F0030584',
                                         'F0030521',
                                         'F0030066',
                                         'F0030688',
                                         'F0030835',
                                         'F0030513',
                                         'F0031403',
                                         'F0030978',
                                         'F0020517',
                                         'F0030542',
                                         'F0031401',
                                         'F0031089',
                                         'F0031090',
                                         'F0031810',
                                         'F0031809',
                                         'F0031803');

-- Permissões de inclusão para os usuários pré-definidos pela CECRED
INSERT INTO crapace
    (nmdatela,
     cddopcao,
     cdoperad,   
     nmrotina,   
     cdcooper,   
     nrmodulo,   
     idevento,   
     idambace)
    SELECT 'CADPCN', 
           'I',
           ope.cdoperad,
           ' ',
           cop.cdcooper,
           1,
           0,
           2
      FROM crapcop cop,
           crapope ope
     WHERE cop.cdcooper IN (14) /*14);*/ 
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND trim(upper(ope.cdoperad)) IN ('1', -- super usuário
                                         'F0030584',
                                         'F0030521',
                                         'F0030066',
                                         'F0030688',
                                         'F0030835',
                                         'F0030513',
                                         'F0031403',
                                         'F0030978',
                                         'F0020517',
                                         'F0030542',
                                         'F0031401',
                                         'F0031089',
                                         'F0031090',
                                         'F0031810',
                                         'F0031809',
                                         'F0031803');

-- Permissões de exclusão para os usuários pré-definidos pela CECRED
INSERT INTO crapace
    (nmdatela,
     cddopcao,
     cdoperad,   
     nmrotina,   
     cdcooper,   
     nrmodulo,   
     idevento,   
     idambace)
    SELECT 'CADPCN', 
           'E',
           ope.cdoperad,
           ' ',
           cop.cdcooper,
           1,
           0,
           2
      FROM crapcop cop,
           crapope ope
     WHERE cop.cdcooper IN (14) /*14);*/ 
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND trim(upper(ope.cdoperad)) IN ('1', -- super usuário
                                         'F0030584',
                                         'F0030521',
                                         'F0030066',
                                         'F0030688',
                                         'F0030835',
                                         'F0030513',
                                         'F0031403',
                                         'F0030978',
                                         'F0020517',
                                         'F0030542',
                                         'F0031401',
                                         'F0031089',
                                         'F0031090',
                                         'F0031810',
                                         'F0031809',
                                         'F0031803');

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
           'CADPCN',
           'Cadastro de valor maximo por CNAE',
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
     WHERE cdcooper IN (14); /*14);*/ 

commit;
end;


             
    
