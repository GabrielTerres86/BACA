BEGIN  
 insert into CECRED.crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'TANQUE','@',crapope.cdoperad,null,3,1,0,2
  from CECRED.crapope 
  where lower(crapope.cdoperad) IN(
	'f0032543',
	'f0030606',
	'f0033550',
	'f0033197',
	'f0033184',
  'f0034735',
  'f0034744',
  'f0034308',
  'f0033589',
  'f0033656',
	't0036027') 
    and crapope.cdsitope = 1
    and crapope.cdcooper = 3; 
 
  insert into CECRED.crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'TANQUE','C',crapope.cdoperad,null,3,1,0,2
  from CECRED.crapope 
  where lower(crapope.cdoperad) IN(
	'f0032543',
	'f0030606',
	'f0033550',
	'f0033197',
	'f0033184',
  'f0034744',
  'f0034308',
  'f0033589',
  'f0033656',
	't0036027')
    and crapope.cdsitope = 1
    and crapope.cdcooper = 3;     
  COMMIT;
END;