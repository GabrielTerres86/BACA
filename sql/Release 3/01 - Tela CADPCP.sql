 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela CADPCP - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Realizar o cadastro da nova tela CADPCP no Ayllos Web
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- remove qualquer "lixo" de BD que possa ter  
delete from craptel where nmdatela = 'CADPCP';
delete from crapace where nmdatela = 'CADPCP';
delete from crapprg where cdprogra = 'CADPCP';
delete from crapaca where nrseqrdr = (select nrseqrdr from craprdr where nmprogra = 'TELA_CADPCP') ;
delete from craprdr where nmprogra = 'TELA_CADPCP';

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
     WHERE flgativo = 1; 

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
    SELECT 'CADPCP', -- permisssões de consulta para o super usuário 
           'C',
           '1',
           ' ',
           cdcooper,
           1,
           0,
           2
      FROM crapcop
     WHERE flgativo = 1
     UNION 
    SELECT 'CADPCP', -- permisssões de alteração para o super usuário
           'A',
           '1',
           ' ',
           cdcooper,
           1,
           0,
           2
      FROM crapcop
     WHERE flgativo = 1 
     UNION
    SELECT 'CADPCP', -- permissões de consulta para os usuários pré-definidos pela CECRED
           'C',
           ope.cdoperad,
           ' ',
           cop.cdcooper,
           1,
           0,
           2
      FROM crapcop cop,
           crapope ope
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND trim(upper(ope.cdoperad)) IN ('F0030584',
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
                                         'F0031803')
     UNION
    SELECT 'CADPCP', -- permissões de alteração para os usuários pré-definidos pela CECRED
           'A',
           ope.cdoperad,
           ' ',
           cop.cdcooper,
           1,
           0,
           2
      FROM crapcop cop,
           crapope ope
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND trim(upper(ope.cdoperad)) IN ('F0030584',
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
     WHERE flgativo = 1;

-- Insere os registros de acesso a inteface web via mensageria
INSERT INTO craprdr (nrseqrdr, nmprogra, dtsolici)
     VALUES (SEQRDR_NRSEQRDR.NEXTVAL, 'TELA_CADPCP', SYSDATE);

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'CADPCP_BUSCA_CONTA', 'TELA_CADPCP', 'pc_busca_conta', 'pr_nrdconta', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADPCP'));

INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
     VALUES (SEQACA_NRSEQACA.NEXTVAL, 'CADPCP_ALTERAR_PAGADOR', 'TELA_CADPCP', 'pc_alterar_pagador', 'pr_nrdconta,pr_nrinssac,pr_vlpercen', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADPCP'));


commit;
end;


             
    
