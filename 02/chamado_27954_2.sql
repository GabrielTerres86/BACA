--- chamado INC0027954 - Arq C00406 - Excluir registros do arquivo BB - cheques da conta ITG
--- A��o: Alterar Flag para = 2- Processado, de registros de cheques j� compensados e que ao serem recusados pelo banco, 
----      sempre s�o reenviados pelos sistema.


update crapcch 
set    crapcch.flgctitg = 2
WHERE crapcch.cdcooper = 1      
  and crapcch.nrdconta = 1885839  
  and crapcch.rowid = 'AAAS+DAKvAABF1CAAU';

Commit;

