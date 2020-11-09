begin 
  -- Remover acesso de todas telas com liberação durante Batch
  update craptel 
     set craptel.inacesso = 1
   where craptel.inacesso = 2;

  -- Permitir durante Batch somente estas
  update craptel 
     set craptel.inacesso = 2
   where craptel.nmdatela IN('EXTRAT','TAB085','CADFRA','FLUXOS','CADTEL','PSPPIX','LOGPIX','CADPIX','CONPIX');

  commit;
  
end;  
