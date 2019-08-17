begin
  
  -- Conta 2597926 / 1=Viacredi
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto in(31108,31511);
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - (9842.00 + 9842.00)
   WHERE cdcooper = 1
     AND nrdconta = 2597926;   
    
  COMMIT;
end;