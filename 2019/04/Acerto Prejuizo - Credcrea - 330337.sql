begin

  -- Conta 330337 / 7=Credcrea
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (15104, 15899);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - (9.9 + 9.9)
   WHERE cdcooper = 7
     AND nrdconta = 330337;
  -- FIM - Conta 330337 / 7=Credcrea

  COMMIT;
end;