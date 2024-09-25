begin
  

update cecred.gnconve e
  set  e.flgdebfacil = 0
where  e.cdconven = 264;

commit;
end;
