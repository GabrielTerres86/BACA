 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela APRDES - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Realizar o cadastro da nova tela APRDES no Ayllos Web
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- remove qualquer "lixo" de BD que possa ter  
/*
DELETE FROM craptel WHERE nmdatela = 'APRDES';
DELETE FROM crapace WHERE nmdatela = 'APRDES';
DELETE FROM crapprg WHERE cdprogra = 'APRDES';
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
     WHERE cdcooper IN (SELECT cdcooper FROM crapprm WHERE cdacesso = 'FL_VIRADA_BORDERO' AND dsvlrprm = '1'); 

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
     WHERE cop.cdcooper IN (SELECT cdcooper FROM crapprm WHERE cdacesso = 'FL_VIRADA_BORDERO' AND dsvlrprm = '1')
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND trim(upper(ope.cdoperad)) IN ('1', --  super usuário
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
           'APRDES',
           'Mesa de checagem',
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
     WHERE cdcooper IN (SELECT cdcooper FROM crapprm WHERE cdacesso = 'FL_VIRADA_BORDERO' AND dsvlrprm = '1');

commit;
end;