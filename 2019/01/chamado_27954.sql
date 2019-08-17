--- chamado INC0027954 - Arq C00406 - Excluir registros do arquivo BB - cheques da conta ITG
--- Ação: Alterar Flag para = 2- Processado, de registros de cheques já compensados e que ao serem recusados pelo banco, 
----      sempre são reenviados pelos sistema.


update crapcch 
set    crapcch.flgctitg = 2
WHERE crapcch.cdcooper = 1      
  and crapcch.nrdconta = 1885839  
  and crapcch.rowid in ('AAAS+DAK0AAAlHzAAM'
,'AAAS+DAKvAABF0TAAD'
,'AAAS+DAK0AAAlGuAAM');

Commit;

