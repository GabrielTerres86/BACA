UPDATE craptel
   SET cdopptel = '@,A,B,X,C,L,E,M,P,I,T,H,S',
       lsopptel = 'ACESSO,ALTERACAO,BLOQUEIO,CANCELAMENTO,CONSULTA,ENTREGA,EXCLUSAO,IMPRESSAO,IMPORTAR,INCLUSAO,LIMITE,SENHA,SOLICITACAO'
 WHERE nmdatela = 'OPERAD' AND UPPER(NMROTINA) = 'MAGNETICO' AND cdcooper = 3;

UPDATE craptel
   SET cdopptel = 'A,B,C,D,I,L,M,N,P,S,V,X,T',
       lsopptel = 'ALTERACAO,BLOQUEIO,CONSULTA,DUPLICACAO,INCLUSAO,LIBERACAO,CARTAO MAGNETICO,ALCADA CREDITO,IMPORTAR,SENHA,VALORES,REPLICACAO,RESTRITO'
 WHERE nmdatela = 'OPERAD' AND UPPER(NMROTINA) = ' ' AND cdcooper = 3;

-- Efetuar commit
COMMIT;