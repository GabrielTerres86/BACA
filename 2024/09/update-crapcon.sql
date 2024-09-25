begin
  
update cecred.crapcon n
  set  n.flginter = 1
where  n.cdempcon = 262;

commit;
end;
