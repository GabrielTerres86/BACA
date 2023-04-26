begin
  
update cecred.crapfdc c
  set c.incheque = 8,
      c.dtliqchq = to_date('27/04/2023','DD/MM/YYYY'),
      c.dtretchq = to_date('27/04/2023','DD/MM/YYYY')
where c.cdcooper = 11
  and c.dtemschq <= TO_DATE('31/03/2021','DD/MM/YYYY')
  and c.dtretchq is null
  and c.progress_recid >= 31865673
  and c.progress_recid <= 61846277;
    
commit;
end;
