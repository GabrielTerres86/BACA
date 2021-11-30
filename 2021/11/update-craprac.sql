BEGIN
  
  update craprac 
     set vlbasapl = 0.02,
         vlsldatl = 0 
   where cdcooper = 1 
     and nrdconta = 8322082
     and nraplica = 3  ; 
    
  update craprac 
     set vlbasapl = 0.02,
         vlsldatl = 0 
   where cdcooper = 1 
     and nrdconta = 8571961
     and nraplica = 3  ;
   
   update craprac 
     set vlbasapl = 0.01,
         vlsldatl = 0 
   where cdcooper = 1 
     and nrdconta = 12644307
     and nraplica = 7;  
    
   update craprac 
      set vlbasapl = 0.02,
         vlsldatl = 0 
   where cdcooper = 16 
     and nrdconta = 116033
     and nraplica = 22; 

  commit;
  
END;       
