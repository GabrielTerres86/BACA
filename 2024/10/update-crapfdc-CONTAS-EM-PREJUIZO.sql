begin
  
update cecred.crapfdc c
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where progress_recid in
(select c.progress_recid
  from crapfdc c      
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 5 
  and  s.cdsitdct in (2,8,3) 
  and  c.nrdconta = 340529
  and  c.incheque = 0
  and  c.dtretchq is null
  
UNION

select c.progress_recid
  from crapfdc c      
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 9 
  and  s.cdsitdct in (2,8,3) 
  and  c.nrdconta in (444219)
  and  c.incheque = 0
  and  c.dtretchq is null
  
UNION  

select c.progress_recid
  from crapfdc c 
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 9 
  and  c.nrdconta = 900702
  and  c.incheque = 0
  and  c.dtretchq is null);
 

commit;
end;
