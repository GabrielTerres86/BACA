begin
  update crawepr w
     set w.dtvencto = to_date('10/08/2022','dd/mm/rrrr')
       , w.dtdpagto = to_date('10/08/2022','dd/mm/rrrr')
   where w.cdcooper = 11
     and w.nrdconta = 787841
     and w.nrctremp = 193167;
  commit;
end;
/
