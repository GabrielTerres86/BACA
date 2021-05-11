BEGIN  
 insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'LIMITE','@',crapope.cdoperad,null,3,1,0,2
  from crapope 
  where lower(crapope.cdoperad) IN('f0031156','f0032201','f0033184') 
    and crapope.cdsitope = 1
    and crapope.cdcooper = 3; 
 
  insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'LIMITE','C',crapope.cdoperad,null,3,1,0,2
  from crapope 
  where lower(crapope.cdoperad) IN('f0031156','f0032201','f0033184') 
    and crapope.cdsitope = 1
    and crapope.cdcooper = 3; 

  insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'LIMITE','I',crapope.cdoperad,null,3,1,0,2
  from crapope 
  where lower(crapope.cdoperad) IN('f0031156','f0032201','f0033184') 
    and crapope.cdsitope = 1
    and crapope.cdcooper = 3;
    
  insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'LIMITE','A',crapope.cdoperad,null,3,1,0,2
  from crapope 
  where lower(crapope.cdoperad) IN('f0031156','f0032201','f0033184') 
    and crapope.cdsitope = 1
    and crapope.cdcooper = 3;
    
  insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'LIMITE','E',crapope.cdoperad,null,3,1,0,2
  from crapope 
  where lower(crapope.cdoperad) IN('f0031156','f0032201','f0033184') 
    and crapope.cdsitope = 1
    and crapope.cdcooper = 3;  
    
  COMMIT;
END;
