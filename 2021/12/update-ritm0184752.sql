begin
  
update crapfdc c
  set c.incheque = 8, c.dtretchq = trunc(sysdate), c.dtliqchq = trunc(sysdate)
where  c.cdcooper = 1
  and  c.incheque = 0
  and  c.dtliqchq is null
  and  c.dtretchq is null
  and  c.cdbantic = 0
  and  c.dtemschq between to_date('01/06/2020','DD/MM/YYYY') and to_date('14/06/2021','DD/MM/YYYY');
  
commit;
end;  
