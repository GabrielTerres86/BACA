begin
  update cecred.crapseg p 
   set p.cdsitseg = 5
  where p.cdcooper = 16
  and p.nrdconta = 85412325 
  and p.nrctrseg = 287849;
  commit;
end;
