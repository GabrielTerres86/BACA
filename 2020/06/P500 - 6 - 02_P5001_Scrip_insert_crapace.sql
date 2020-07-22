 /* Realizar a inclus�o na tela UPPGTO conforme as novas op��es para a importa��o dee Transfer�ncia e Teds*/

  /* Op��o M - Consultar movimento de remessa */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, 'M', ace.cdoperad, ace.nmrotina, ace.cdcooper, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where ace.nmdatela = 'UPPGTO'
  and ace.cddopcao = 'E';  --C
  
  /* Op��o G - Gerar movimento de remessa */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, 'G', ace.cdoperad, ace.nmrotina, ace.cdcooper, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where ace.nmdatela = 'UPPGTO'
  and ace.cddopcao = 'E'; --R
  
   
  /* Op��o K - Kit de Materiais */
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, 'K', ace.cdoperad, ace.nmrotina, ace.cdcooper, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where ace.nmdatela = 'UPPGTO'
  and ace.cddopcao = 'E'; --R  
  
  /* Op��o H - Homologar Arquivo de Remessa*/
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, 'H', ace.cdoperad, ace.nmrotina, ace.cdcooper, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where ace.nmdatela = 'UPPGTO'
  and ace.cddopcao = 'E';

  Commit;
  
  

  

  
   
    


