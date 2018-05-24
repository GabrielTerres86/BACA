insert into crapace 
(nmdatela  
,cddopcao  
,cdoperad  
,nmrotina  
,cdcooper  
,nrmodulo  
,idevento  
,idambace  )
select 
 nmtela
,CDDOPCAO --'C' de consulta
,CDOPERAD
,' ' --nmrotina
,CDCOOPER
, nrmodulo
,  idevento
,  IDAMBACE
from (
select distinct 
'CONDEB' nmtela
,A.CDDOPCAO --'C' de consulta
,a.CDOPERAD
--,a.nmrotina
,a.CDCOOPER
,1  nrmodulo
,0  idevento
,2  IDAMBACE
from crapace a
where a.nmdatela = 'ATENDA'
AND A.CDDOPCAO = 'C'
AND A.IDEVENTO = 0
AND A.IDAMBACE = 2
and exists (select 1
    from crapope b
    where b.CDSITOPE = 1
   and b.dtaltsnh >= '01/06/2017'
    and b.cdoperad = a.cdoperad
    and b.cdcooper = a.cdcooper)
    );
  
commit;  