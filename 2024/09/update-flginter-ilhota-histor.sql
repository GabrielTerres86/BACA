begin
  
update cecred.gnconve v
  set v.cdhiscxa = 4568
where  v.cdconven = 276;

update cecred.crapcon c
  set c.cdhistor = 4568
WHERE c.cdempcon = 4746 
  and c.cdsegmto = 2;

commit;
end;
