begin
update crapseg p
  set p.cdsitseg = 5
where p.cdcooper = 7
and p.nrdconta = 99733013
and p.nrctrseg = 174274;
   commit;
end;
/
