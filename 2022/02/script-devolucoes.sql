begin
  
update crapfdc c 
  set c.incheque = 0
where c.cdcooper = 8 
  and c.dtliqchq = to_date('21/01/2022','DD/MM/YYYY');  
commit;

delete crapdev v 
where v.cdcooper = 3;
commit;

end;
