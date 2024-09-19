begin
  
update cecred.gnconve v
  set v.flginter = 1
where  v.cdconven = 276;

update cecred.crapcon c
  set c.flginter = 1
WHERE c.cdempcon = 4746 
  and c.cdsegmto = 2;

commit;
end;
