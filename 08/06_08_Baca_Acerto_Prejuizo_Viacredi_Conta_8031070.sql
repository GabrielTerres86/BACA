 BEGIN
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto IN (34101);

    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - 1453.00
     WHERE cdcooper = 1
       AND nrdconta = 8031070;
       commit;
  END;