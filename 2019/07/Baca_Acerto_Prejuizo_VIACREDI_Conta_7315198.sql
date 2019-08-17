BEGIN
    -- 17/07
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto IN (32582);

    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - 8000.0
     WHERE cdcooper = 1
       AND nrdconta = 7315198;
    --  19/07
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto IN (32676);

    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - 8000.0
     WHERE cdcooper = 1
       AND nrdconta = 7315198;  
    commit;     
  END;