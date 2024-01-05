BEGIN  
 insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'TANQUE','@',crapope.cdoperad,null,3,1,0,2
  from crapope 
  where lower(crapope.cdoperad) IN(
	'f0033406',
	'f0030606',
	'f0033550',
	'f0033197',
	'f0033739',
	'f0030614',
	'f0030191',
	'f0030640',
	'f0033467',
	'f0033559',
	'f0033734',
	'f0034561',
	't0036027') 
    and crapope.cdsitope = 1
    and crapope.cdcooper = 3; 
 
  insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'TANQUE','C',crapope.cdoperad,null,3,1,0,2
  from crapope 
  where lower(crapope.cdoperad) IN(
	'f0033406',
	'f0030606',
	'f0033550',
	'f0033197',
	'f0033739',
	'f0030614',
	'f0030191',
	'f0030640',
	'f0033467',
	'f0033559',
	'f0033734',
	'f0034561',
	't0036027')
    and crapope.cdsitope = 1
    and crapope.cdcooper = 3;     
  COMMIT;
END;
