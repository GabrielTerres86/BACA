begin

update cecred.crawseg w
  set w.vlpremio = 309.58
where nrproposta = '202305311243'
  and cdcooper = 11
  and nrdconta = 311774
  and nrctrseg = 307090;

update cecred.crapseg s
   set s.vlpremio = 309.58
 where cdcooper = 11
   and nrdconta = 311774
   and nrctrseg = 307090
   and tpseguro = 4;
   
update cecred.tbseg_prestamista t
   set t.vlprodut = 309.58
 where nrproposta = '202305311243'
   and cdcooper = 11
   and nrdconta = 311774
   and nrctrseg = 307090;
   
commit;
end;   
 
    
