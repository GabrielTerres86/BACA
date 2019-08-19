update crapttl ct 
set ct.grescola = 10
where not exists (select 1 from CECRED.GNGRESC g where g.grescola = ct.grescola);

commit;
