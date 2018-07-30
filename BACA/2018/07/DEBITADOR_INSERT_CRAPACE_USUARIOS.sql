insert into crapace 
(nmdatela  
,cddopcao  
,cdoperad  
,nmrotina  
,cdcooper  
,nrmodulo  
,idevento  
,idambace  )
select  distinct
 'PARDBT' nmtela
,'C' CDDOPCAO
,CDOPERAD
,' ' --nmrotina
,3 CDCOOPER
,1  nrmodulo
,0  idevento
,2  IDAMBACE
from (
select distinct 
upper(a.CDOPERAD) CDOPERAD
from crapace a
where a.nmdatela = 'CONDEB'
AND A.CDDOPCAO = 'C'
and a.cdoperad not in  ('f0030400','f0030250','f0030344','f0030463')
and exists (select 1
    from crapope b
    where b.CDSITOPE = 1
    and b.dtaltsnh >= '01/01/2018'
     and b.dtaltsnh < '01/02/2018'
    and b.cdoperad = a.cdoperad
    and b.cdcooper = a.cdcooper)
    );
	
commit;	