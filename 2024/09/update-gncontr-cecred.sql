begin
  
update cecred.gncontr gncontr
  set gncontr.nrsequen = 454
where gncontr.cdcooper = 3
  and gncontr.tpdcontr = 3 
  and gncontr.cdconven = 76
  and gncontr.nrsequen = 450;
  
commit;
end;  
