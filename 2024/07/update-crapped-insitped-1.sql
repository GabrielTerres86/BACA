begin
   
update cecred.crapped d
  set  d.insitped = 0
where  d.cdcooper = 1   
  and  d.nrpedido = 179003;  
  
commit;
end;
