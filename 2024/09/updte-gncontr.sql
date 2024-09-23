begin
update cecred.gncontr 
       tpdcontr = 4
where cdconven in (172,173) 
  and tpdcontr = 1;
commit; 
end;
