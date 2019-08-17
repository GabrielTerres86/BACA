 /* Realizar as mudanças na tela CONSPB conforme o novo prototipo e funcionalidades*/

  --Incluir as opções "@", "C" com as mesmas informações do "P" para todos os registro do programa CONSPB
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, '@', ace.cdoperad, ace.nmrotina, ace.cdcooper, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where ace.nmdatela = 'CONSPB'
  and ace.cddopcao = 'P';

  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, 'C', ace.cdoperad, ace.nmrotina, ace.cdcooper, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where ace.nmdatela = 'CONSPB'
  and ace.cddopcao = 'P';  
  

  
  Commit;
   
    


