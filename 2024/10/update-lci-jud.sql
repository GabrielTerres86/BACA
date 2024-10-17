BEGIN
  
  update investimento.TBINVEST_RESGATE_JUDICIAL_LCI
     set insituacao = 4
   where nrdconta = 869449   
     and nraplica = 2908
     and dtresgate = to_date('15/10/2024','dd/mm/yyyy');
  COMMIT;
  
 EXCEPTION
   WHEN OTHERS then

         ROLLBACK; 
END;       
