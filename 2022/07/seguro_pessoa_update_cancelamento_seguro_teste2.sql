begin   
  update crawseg p
     set p.dtfimvig = to_date('21/05/2022','dd/mm/rrrr')
   where p.cdcooper = 5
     and p.nrdconta = 217964
     and p.nrctrseg = 50185;
     
  update crapseg p
     set p.dtfimvig = to_date('21/05/2022','dd/mm/rrrr')
   where p.cdcooper = 5
     and p.nrdconta = 217964
     and p.nrctrseg = 50185;
     
  update tbseg_prestamista p
     set p.dtfimvig = to_date('21/05/2022','dd/mm/rrrr')
   where p.cdcooper = 5
     and p.nrdconta = 217964
     and p.nrctrseg = 50185;
     
  update crapseg p
     set p.cdmotcan = 20,
         p.dtcancel = to_date('21/06/2022','dd/mm/rrrr'),
         p.cdsitseg = 2
   where p.cdcooper = 5
     and p.nrdconta = 217964
     and p.nrctrseg = 50185;
   commit; 
end;
/
