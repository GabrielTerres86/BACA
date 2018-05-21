 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela CADPCP - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Realizar o cadastro da nova tela CADPCP no Ayllos Web
  ---------------------------------------------------------------------------------------------------------------------*/

BEGIN

-- remove qualquer "lixo" de BD que possa ter  
/*
DELETE FROM craptel WHERE nmdatela = 'CADPCP';
DELETE FROM crapace WHERE nmdatela = 'CADPCP';
DELETE FROM crapprg WHERE cdprogra = 'CADPCP';
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
    SELECT 'CADPCP', 
           5, 
           'C,A', 
           'Cadastro de porcentagem de pagador', 
           'Cadastro de porcentagem de pagador', 
           0, 
           1, -- bloqueio da tela 
           ' ', 
           'CONSULTA,ALTERAR', 
           0, 
           cdcooper, -- cooperativa
           1, 
           0, 
           1, 
           1, 
           '', 
           2 
      FROM crapcop          
     WHERE cdcooper IN (SELECT cdcooper FROM crapprm WHERE cdacesso = 'FL_VIRADA_BORDERO' AND dsvlrprm = 'P'); 

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
    SELECT 'CADPCP', 
           'C',
           ope.cdoperad,
           ' ',
           cop.cdcooper,
           1,
           0,
           2
      FROM crapcop cop,
           crapope ope
     WHERE cop.cdcooper IN (SELECT cdcooper FROM crapprm WHERE cdacesso = 'FL_VIRADA_BORDERO' AND dsvlrprm = 'P')
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
    SELECT 'CADPCP', 
           'A',
           ope.cdoperad,
           ' ',
           cop.cdcooper,
           1,
           0,
           2
      FROM crapcop cop,
           crapope ope
     WHERE cop.cdcooper IN (SELECT cdcooper FROM crapprm WHERE cdacesso = 'FL_VIRADA_BORDERO' AND dsvlrprm = 'P')
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
           'CADPCP',
           'Cadastro de porcentagem de pagador',
           '.',
           '.',
           '.',
           (SELECT max(nrsolici)+1 FROM crapprg),
           NULL,
           1,
           0,
           0,
           0,
           0,
           0,
           1,
           cdcooper
      FROM crapcop          
     WHERE cdcooper IN (SELECT cdcooper FROM crapprm WHERE cdacesso = 'FL_VIRADA_BORDERO' AND dsvlrprm = 'P');

commit;
end;


             
    
