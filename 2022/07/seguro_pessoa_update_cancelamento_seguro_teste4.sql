begin
  update crapseg p
     set p.cdmotcan = 20,
         p.dtcancel = to_date('21/06/2022','dd/mm/rrrr'),
         p.cdsitseg = 2
   where p.cdcooper = 9
     and p.nrdconta = 459070
     and p.nrctrseg = 17971;
   commit; 
end;
/
