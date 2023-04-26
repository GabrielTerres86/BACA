begin

update cecred.crawseg 
   set vlpremio = 65.19
 where cdcooper = 13
   and nrdconta = 499455
   and nrproposta = '202304200196';
   
update cecred.crapseg 
   set vlpremio = 65.19
 where cdcooper = 13
   and nrdconta = 499455
   and nrctrseg = 447624;   
   
update cecred.tbseg_prestamista 
   set vlprodut = 65.19
 where cdcooper = 13
   and nrdconta = 499455
   and nrproposta = '202304200196'; 

commit;   

end;