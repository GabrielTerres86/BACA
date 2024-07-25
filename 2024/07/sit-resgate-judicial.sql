BEGIN

  UPDATE investimento.tbinvest_resgate_judicial_lci
     SET insituacao = 5 
   WHERE cdcooper = 10
     AND nrdconta = 17277060
     AND nraplica = 7912
     AND dtresgate = to_date('08/07/2024','dd/mm/yyyy');
     
  UPDATE investimento.tbinvest_resgate_judicial_lci
     SET insituacao = 5 
   WHERE cdcooper = 7
     AND nrdconta = 41831
     AND nraplica = 11311
     AND dtresgate = to_date('12/07/2024','dd/mm/yyyy');     
     
  COMMIT;
  
END;     
