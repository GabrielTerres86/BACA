begin   
  update crawseg p
     set p.dtfimvig = to_date('21/05/2022','dd/mm/rrrr')
   where p.cdcooper = 5
     and p.nrdconta = 14675250
     and p.nrctrseg = 50263;
     
  update crapseg p
     set p.dtfimvig = to_date('21/05/2022','dd/mm/rrrr')
   where p.cdcooper = 5
     and p.nrdconta = 14675250
     and p.nrctrseg = 50263;
     
  update tbseg_prestamista p
     set p.dtfimvig = to_date('21/05/2022','dd/mm/rrrr')
   where p.cdcooper = 5
     and p.nrdconta = 14675250
     and p.nrctrseg = 50263;
   commit; 
end;
/
