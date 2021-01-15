BEGIN
  UPDATE crapepr t
    SET t.vlsprojt = 9067.99
       ,t.vlsdeved = 9081.79 
    WHERE t.cdcooper = 1
    AND t.nrdconta = 6908179
    AND t.nrctremp = 2460485;

  UPDATE crappep t
    SET t.vlparepr = 4588.17
    WHERE t.cdcooper = 1
    AND t.nrdconta = 6908179
    AND t.nrctremp = 2460485
    AND t.nrparepr = 1;

  UPDATE crappep t
    SET t.vlparepr = 4566.12
       ,t.vlsdvpar = 4566.12
    WHERE t.cdcooper = 1
    AND t.nrdconta = 6908179
    AND t.nrctremp = 2460485
    AND t.nrparepr = 2;

  UPDATE crappep t
    SET t.vlparepr = 4564.77
       ,t.vlsdvpar = 4564.77
    WHERE t.cdcooper = 1
    AND t.nrdconta = 6908179
    AND t.nrctremp = 2460485
    AND t.nrparepr = 3;

  UPDATE crappep t
    SET t.vlparepr = 4564.77
       ,t.vlsdvpar = 4564.77
    WHERE t.cdcooper = 1
    AND t.nrdconta = 6908179
    AND t.nrctremp = 2460485
    AND t.nrparepr = 4;

COMMIT;
END;
