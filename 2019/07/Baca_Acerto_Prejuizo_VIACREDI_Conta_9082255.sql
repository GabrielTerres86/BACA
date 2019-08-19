BEGIN
    -- 23/07
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto IN (32819);

    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - 200.0
     WHERE cdcooper = 1
       AND nrdconta = 9082255;
    commit;     
  END;
