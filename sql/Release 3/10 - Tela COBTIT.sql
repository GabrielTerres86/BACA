 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela COBTIT - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Luis Fernando (GFT)
    Data        : Maio/2018
    Objetivo    : Realizar o cadastro da nova tela COBTIT no Ayllos Web
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- remove qualquer "lixo" de BD que possa ter  
/*
DELETE FROM craptel WHERE nmdatela = 'COBTIT';
DELETE FROM crapace WHERE nmdatela = 'COBTIT';
DELETE FROM crapprg WHERE cdprogra = 'COBTIT';
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
    SELECT 'COBTIT', 
           5, 
           '@,C,B,G,X,D,Y', 
           'Cobrança de Títulos', 
           'Cobrança de Títulos', 
           0, 
           1, -- bloqueio da tela 
           ' ', 
           'Acesso,Consultar,Baixa,Gerar Boleto,Enviar Email/SMS,Desconto Prejuizo,Boletagem Massiva', 
           0, 
           cdcooper, -- cooperativa
           1, 
           0, 
           1, 
           1, 
           '', 
           2 
      FROM crapcop          
     WHERE cdcooper IN (select cdcooper from crapcop where flgativo=1); 

-- Permissões de consulta para os usuários pré-definidos pela CECRED                       
INSERT INTO crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace) (SELECT 'COBTIT',cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace FROM crapace WHERE nmdatela ='COBEMP');
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
           'COBTIT',
           'Cobrança de Títulos',
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
     WHERE cdcooper IN (select cdcooper from crapcop where flgativo=1);

UPDATE crapprg c SET cdrelato##1=(SELECT cdrelato##1 FROM crapprg WHERE cdprogra = 'COBEMP' AND cdcooper = 3) WHERE cdprogra='COBTIT' AND cdcooper = 3;

commit;
end;