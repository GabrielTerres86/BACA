begin
  
  -- Conta 137685 / 9=Transpocred
  DELETE FROM tbcc_prejuizo_detalhe 
   WHERE idlancto IN (15758);
   
  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 13.82
   WHERE cdcooper = 9
     AND nrdconta = 137685;
  -- FIM - Conta 137685 / 9=Transpocred
     
  COMMIT;
end;