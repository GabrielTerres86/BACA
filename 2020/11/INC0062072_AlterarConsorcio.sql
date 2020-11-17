update crapcns  set flgativo = 0, cdsitcns = case when  dtctpcns is null then 'TRA' else 'QUI' end 
 where dtfimcns < trunc(sysdate)
   and flgativo = 1
   and cdsitcns = ' '
   and dtfimcns >= '25/01/2015'
   and exists ( select 1 from   crapcop p where p.flgativo = 1 and crapcns.cdcooper = p.cdcooper)
   ;
commit ;
 