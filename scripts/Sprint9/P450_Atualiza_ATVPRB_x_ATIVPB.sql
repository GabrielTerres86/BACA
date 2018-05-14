 
-- MUDA NOME RDR
 update craprdr
   set craprdr.nmprogra = 'TELA_ATIVPB'                    
 where craprdr.nmprogra = 'TELA_ATVPRB';

-- MUDA NOME PRG
update crapprg
   set crapprg.cdprogra = 'ATIVPB'                    
 where crapprg.cdprogra = 'ATVPRB';

-- MUDA NOME TEL
update craptel
   set craptel.nmdatela = 'ATIVPB'                    
 where craptel.nmdatela = 'ATVPRB';

-- MUDA ACA PRINCIPAL
update crapaca
   set crapaca.nmpackag = 'TELA_ATIVPB'                    
 where crapaca.nmpackag = 'TELA_ATVPRB';

-- MUDA ACA OPCAO ALTERACAO
update crapaca
   set crapaca.nmdeacao = 'ATIVPB_ALTERACAO'                    
 where crapaca.nmdeacao = 'ATVPRB_ALTERACAO';

-- MUDA ACA OPCAO CONSULTA / PARAMETROS
update crapaca
   set crapaca.nmdeacao = 'ATIVPB_CONSULTA'  
     , lstparam = 'pr_idativo,pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_cdmotivo,pr_datainic,pr_datafina, pr_pagina'
 where crapaca.nmdeacao = 'ATVPRB_CONSULTA';

-- MUDA ACA OPCAO INCLUIR
update crapaca
   set crapaca.nmdeacao = 'ATIVPB_INCLUSAO'                    
 where crapaca.nmdeacao = 'ATVPRB_INCLUSAO';

-- MUDA ACA OPCAO EXCLUSAO
update crapaca
   set crapaca.nmdeacao = 'ATIVPB_EXCLUSAO'                    
 where crapaca.nmdeacao = 'ATVPRB_EXCLUSAO';

 
-- MUDA ACA OPCAO LISTA MOTIVOS
update crapaca
   set crapaca.nmdeacao = 'ATIVPB_LISTA_MOTIVOS'                    
 where crapaca.nmdeacao = 'ATVPRB_LISTA_MOTIVOS';
 
-- REMOVER PACKAGE ANTIGA
DROP PACKAGE TELA_ATVPRB;


COMMIT;