begin

update seguro.tbseg_contrato_socio_pj 
   set vlcobertura = 700000
 where cdcooper = 5 
   and nrdconta = 99966140 
   and nrctrseg = 147249;

commit;
end;