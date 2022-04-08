begin
  update crapseg p
     set p.cdsitseg = 2
   where p.cdcooper = 14
     and p.nrdconta = 157090
     and p.nrctrseg = 41094;
  commit;
end;
/
