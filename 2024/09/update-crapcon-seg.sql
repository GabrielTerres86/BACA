begin
  
update cecred.crapcon n
  set  n.cdsegmto = 2
where  n.cdempcon = 262;

commit;
end;
