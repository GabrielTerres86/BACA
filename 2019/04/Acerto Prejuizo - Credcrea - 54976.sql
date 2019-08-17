begin

  -- Conta 54976 / 7=Credcrea
  DELETE FROM tbcc_prejuizo_detalhe
   WHERE idlancto IN (15900);

  UPDATE tbcc_prejuizo
     SET vlsdprej = vlsdprej - 9.9
   WHERE cdcooper = 7
     AND nrdconta = 54976;
  -- FIM - Conta 54976 / 7=Credcrea

  COMMIT;
end;