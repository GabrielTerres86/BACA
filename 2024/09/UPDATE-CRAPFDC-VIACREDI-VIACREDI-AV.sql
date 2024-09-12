begin
  
update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate),
      c.dtretchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 16
  and  s.cdsitdct in (2,8,3) 
  and  c.nrdconta = 625388
  and  c.incheque = 0
  and  c.dtretchq is null);
commit;
  
update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 14541920
  and  c.incheque = 0
  and  c.dtretchq is null);
commit;    


update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 13674226
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 14455030
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 14395851
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 13377698
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 13242695
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 13130170
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 13094394
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 11920998
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 11829524
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 11604328
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 11158450
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 11582960
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtretchq = trunc(sysdate),
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 10514147
  and  c.incheque = 0
  and  c.dtretchq is null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 16
  and  s.cdsitdct in (2,8,3) 
  and  c.nrdconta = 625388
  and  c.incheque = 0
  and  c.dtretchq is not null);
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 14541920
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 13674226
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 14455030
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 14395851
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;


update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 13377698
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 13242695
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 13130170
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 13094394
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 11920998
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;


update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 11829524
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 11604328
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 11158450
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 11582960
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

update cecred.crapfdc c 
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate)
where c.progress_recid in 
(select c.progress_recid
  from crapfdc c
inner join crapass s on (s.cdcooper = c.cdcooper and s.nrdconta = c.nrdconta)  
where  c.cdcooper = 1 
  and  s.cdsitdct in (2,8,3) 
  and  s.nrdconta = 10514147
  and  c.incheque = 0
  and  c.dtretchq is not null);  
commit;

end;  
