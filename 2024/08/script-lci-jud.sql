BEGIN
  
   update investimento.tbinvest_resgate_judicial_lci
      set insituacao = 5 
    where dtresgate = to_date('08/08/2024','dd/mm/yyyy')
      and nrdconta = 16192362
      and cdcooper = 10;
      
   COMMIT;

END;   
